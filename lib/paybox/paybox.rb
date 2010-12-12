module Paybox
  class Paybox
    ###################################################################
    # Handle connection and dialog with Paybox online payment servers
    # ------------- Usage ---------------------------
    # # Simply drop this class into your models dir, then
    # # Call class constructor from your controller
    #  response = Paybox.new(
    #    :operation => '00057', 
    #    :amount => 1000, 
    #    :user_id => your_db_customer/suscriber_account_id, 
    #    :card_nbr => card_number_or_encrypted_alias, 
    #    :expire => card_expiration_date (mmyy), 
    #    :cvv2 => card_cvv2_code (3 digits)
    #  ) 
    #
    # Then you can read response like this, for instance :
    #
    # response.coderesponse = '00000' # =>  Cool, successful request
    # ... or 
    # response.commentaire = "PAYBOX : Numéro de porteur invalide" # =>  Oooops, invalid card number given
    # #################################################################
    include HTTParty
    include ActiveModel::Validations

    attr_accessor :operation, :amount, :user_id, :card_nbr, :expire, :cvv2, :numtrans

    #:operation => ":operation . The code of requested operation to be done", 
    #:amount => ":amount . The amount of the transaction", 
    #:user_id => "user_id . The id of your user in your own Database", 
    #:card_nbr => ":card_nbr . The crypted partial card number in your Database", 
    #:expire => ":expire . The expiration date of the card",
    #:cvv2 => ":cvv2 . The CVV2 parameter you should have stored in your DB",
    #:numtrans => ":numtrans . The previous transaction number"   
    validates :operation, :amount, :user_id, :card_nbr, :expire, :cvv2, :presence  =>  true

    # WARNING :numtrans parameter IS REQUIRED only for operations 00002, 00005, 00013, 00017, 00052, 00055 
    validates :numtrans, :presence => true, :if => Proc.new { |obj| NUM_TRANS_REQUIRED_ARRAY.include?(obj.operation) }

    NUM_TRANS_REQUIRED_ARRAY = ['00002', '00005', '000013', '00017', '00052', '00055']

    def initialize(args)
      args.each_pair { |k,v| send("#{k}=",v) }
    end

    def authorize
      raise 'invalid parameters, please check for errors' unless self.valid?

      ##### List of all available operations ###########
      # One-shot operations for customers
      # ------------------------------------------------
      #  00001 = Autorisation, 
      #  00002 = Débit, 
      #  00003 = Autorisation + Débit,
      #  00004 = Crédit, 
      #  00005 = Annulation, 
      #  00011 = Vérification de l’existence d’une transaction, 
      #  00012 = Transaction sans demande d’autorisation, 
      #  00013 = Modification du montant d’une transaction, 
      #  00014 = Remboursement, 
      #  00017 = Consultation

      # Recurring Operations on suscriber accounts
      # -----------------------------------------------
      #  00051 = Autorisation seule sur un abonné, 
      #  00052 = Débit sur un abonné, 
      #  00053 = Autorisation + Débit sur un abonné, 
      #  00054 = Crédit sur un abonné, 
      #  00055 = Annulation d’une opération sur un abonné, 
      #  00056 = Inscription nouvel abonné, 
      #  00057 = Modification abonné existant, 
      #  00058 = Suppression abonné   
      #  00061 = Transaction sans demande d’autorisation (forçage).

      # You can use these three card numbers for tests
      # with any cvv2 3 digits number and any expiration date > this month
      # 1111222233334444
      # 4975660000000004
      # 4970100000025102

      ######## Place YOUR own production parameters here
      # These are actually the test plateform/account parameters
      # You can use them safely while you test your app
      url = URI.parse("https://preprod-ppps.paybox.com")
      site = '1999888'
      rang = '99'
      cle = "1999888I"

      # These params shouldn't change...
      http = Net::HTTP.new(url.host, 443)
      http.use_ssl = true
      path = '/PPPS.php'
      ##############

      # Collect datas in a big hash 
      this_date = Time.now

      datas = {
        :DATEQ => this_date.strftime('%d%m%Y%H%M%S'),
        :TYPE => self.operation,
        :NUMQUESTION => this_date.to_i,
        :MONTANT => self.amount,
        :SITE => site,
        :RANG => rang,
        :REFERENCE => "test",
        :REFABONNE => self.user_id,
        :VERSION => '00104',
        :CLE => cle,
        :IDENTIFIANT => '2',
        :DEVISE => "978",
        :PORTEUR => self.card_nbr,
        :DATEVAL => self.expire,
        :CVV => self.cvv2,
        :ACTIVITE => "024",
        :ARCHIVAGE => "Simplissime.fr",
        :DIFFERE => "000", 
        :NUMAPPEL => "",
        :NUMTRANS => self.numtrans,
        :AUTORISATION => "", 
        :PAYS => "FR"
      }

      # Format request
      headers = {'Content-Type'  =>  'application/x-www-form-urlencoded'}

      formated_datas = ''
      datas.each do |key,value|
        formated_datas == '' ? true : formated_datas << "&"
        formated_datas << "#{key}=#{CGI::escape(value.to_s)}"
      end

      # POST request via Net:HTTP over ssl
      begin
        response, data = http.post(path, formated_datas, headers)
      rescue Exception  =>  e
        puts e.inspect
        # Third party server or transfert error 
        return nil
      end

      # Now we've got a response, let's parse it
      Transaction.new.tap { |trans|
        response.body.split('&').each do |parameter|
        parameter.strip!
        key = parameter.split('=').first
        value = Iconv.conv('utf-8', 'ISO-8859-1', parameter.split('=').last)

        case key
          ###############################################
          # All Paybox response parameters available
        when 'NUMTRANS'
          #Numéro de la transaction créée (int (10))
          trans.numtrans = value  

        when 'NUMAPPEL'
          # Numéro de la requête gérée sur Paybox (int (10))
          trans.numappel = value   

        when 'NUMQUESTION'
          # Identifiant unique et sequentiel (un timestamp sur 10 chiffres )
          trans.numquestion = value 

        when 'SITE'
          # Numéro d'adhérent fourni par la banque (int (7))
          trans.site = value 

        when 'RANG'
          # Numéro de rang fourni par la banque du commerçant (int (2))
          trans.rang = value          

        when 'IDENTIFIANT'
          # Champ vide (int (10))
          trans.identifiant = value                                 

        when 'AUTORISATION'
          # Numéro d'autorisation délivré par le centre d'autorisation de la banque du commerçant si le paiement est accepté (varchar (10))
          trans.autorisation = value 

        when 'CODEREPONSE'
          # Code réponse concernant l'état de la réponse traité, opération acceptée ou refusée (varchar (10))
          trans.codereponse = value 

        when 'REFABONNE'
          # Numéro d'abonné (user) contenu dans la trame question (varchar (250))
          trans.refabonne = value 

        when 'PORTEUR'
          # Numéro porteur partiel (n° carte crypté), Identique à la trame question (varchar (19))
          trans.porteur = value 

        when 'COMMENTAIRE'
          # Messages divers pour information (varchar(100))
          trans.commentaire = value 

        when 'PAYS'
          # Code Pays du porteur de la carte (format ISO 3166)
          trans.pays = value 

        when 'TYPECARTE'
          # Type de carte utilisé (varchar(10))
          trans.typecarte = value 

        when 'SHA-1'
          # Empreinte SHA-1 de la carte utilisée
          trans.sha1 = value 

        when 'STATUS'
          # Etat de la transaction, retourné uniquement avec une question type 17 (=consultation) (varchar (16)) 
          trans.status = value 

        when 'REMISE'
          # Identifiant Paybox de la remise collectée (uniquement en consultation type 17), (int (9))
          trans.remise = value 
        end
        end
      }
    end
  end
end
