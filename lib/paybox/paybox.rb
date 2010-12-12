module Paybox
  class Paybox

    ###################################################################
    # Handle connection and dialog with Paybox online payment servers
    # 
    # This class is given 'as is', feel free to modify and customize it
    # I do NOT garanty any support nor it will work for your purpose  
    # If you enjoyed it, you may send me feedback to gbarillot at gmail dot com
    # Or leave a comment on my blog : http://guillaume-barillot.com
    #
    # ------------- Usage ---------------------------
    # # Simply drop this class into your models dir, then
    # # Call class constructor from your controller
    #  response = Paybox.new(
    #    :operation=>'00057', 
    #    :amount=>1000, 
    #    :user_id=>your_db_customer/suscriber_account_id, 
    #    :card_nbr=>card_number_or_encrypted_alias, 
    #    :expire=>card_expiration_date (mmyy), 
    #    :cvv2=>card_cvv2_code (3 digits)
    #  ) 
    #
    # Then you can read response like this, for instance :
    #
    # response.coderesponse = '00000' #=> Cool, successful request
    # ... or 
    # response.commentaire = "PAYBOX : Numéro de porteur invalide" #=> Oooops, invalid card number given
    # 
    # TODO : tests, and some eventual specific filtering regarding the request you send to Paybox
    # Guillaume Barillot, 30/11/2010
    # #################################################################

    require 'net/https'

    attr_accessor :numtrans, :numappel, :numquestion, :site
    attr_accessor :rang, :identifiant, :autorisation, :codereponse
    attr_accessor :refabonne, :porteur, :commentaire, :pays
    attr_accessor :typecarte, :sha1, :status, :remise

    # Connect, then parse back response
    def initialize(this_transaction)

      # Prepare for some sanity check errors
      required_hash = {
        :operation=>":operation . The code of requested operation to be done", 
        :amount=>":amount . The amount of the transaction", 
        :user_id=>"user_id . The id of your user in your own Database", 
        :card_nbr=>":card_nbr . The crypted partial card number in your Database", 
        :expire=>":expire . The expiration date of the card",
        :cvv2=>":cvv2 . The CVV2 parameter you should have stored in your DB",
        :numtrans=>":numtrans . The previous transaction number"   
      }

      # WARNING :numtrans parameter IS REQUIRED only for operations 00002, 00005, 00013, 00017, 00052, 00055 
      numtrans_required_array = ['00002', '00005', '000013', '00017', '00052', '00055']

      # Let's check if we've got everything (only numtrans is optionnal here)
      required_hash.each do |parameter, name|
        if !this_transaction.has_key?(parameter)
          if(parameter == :numtrans && numtrans_required_array.include?(this_transaction[:operation]))
            raise "Paybox line 61 => Parameter #{name} is required for operation code #{this_transaction[:operation]} !"
          elsif(parameter != :numtrans)
            # Required parameter missing
            raise "Paybox line 64 => Parameter #{name} is missing !"
          end
        end
      end

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
        :DATEQ=>this_date.strftime('%d%m%Y%H%M%S'),
        :TYPE=>this_transaction[:operation],
        :NUMQUESTION=>this_date.to_i,
        :MONTANT=>this_transaction[:amount],
        :SITE=>site,
        :RANG=>rang,
        :REFERENCE=>"test",
        :REFABONNE=>this_transaction[:user_id],
        :VERSION=>'00104',
        :CLE=>cle,
        :IDENTIFIANT=>'2',
        :DEVISE=>"978",
        :PORTEUR=>this_transaction[:card_nbr],
        :DATEVAL=>this_transaction[:expire],
        :CVV=>this_transaction[:cvv2],
        :ACTIVITE=>"024",
        :ARCHIVAGE=>"Simplissime.fr",
        :DIFFERE=>"000", 
        :NUMAPPEL=>"",
        :NUMTRANS=>this_transaction[:numtrans],
        :AUTORISATION=>"", 
        :PAYS=>"FR"
      }

      # Format request
      headers = {'Content-Type' => 'application/x-www-form-urlencoded'}

      formated_datas = ''
      datas.each do |key,value|
        formated_datas == '' ? true : formated_datas << "&"
        formated_datas << "#{key}=#{CGI::escape(value.to_s)}"
      end

      # POST request via Net:HTTP over ssl
      begin
        response, data = http.post(path, formated_datas, headers)
      rescue Exception => e
        puts e.inspect
        # Third party server or transfert error 
        return nil
      end

      # Now we've got a response, let's parse it 
      response.body.split('&').each do |parameter|
        parameter.strip!
        key = parameter.split('=').first
        value = Iconv.conv('utf-8', 'ISO-8859-1', parameter.split('=').last)

        case key
          ###############################################
          # All Paybox response parameters available
        when 'NUMTRANS'
          #Numéro de la transaction créée (int (10))
          @numtrans = value  

        when 'NUMAPPEL'
          # Numéro de la requête gérée sur Paybox (int (10))
          @numappel = value   

        when 'NUMQUESTION'
          # Identifiant unique et sequentiel (un timestamp sur 10 chiffres )
          @numquestion = value 

        when 'SITE'
          # Numéro d'adhérent fourni par la banque (int (7))
          @site = value 

        when 'RANG'
          # Numéro de rang fourni par la banque du commerçant (int (2))
          @rang = value          

        when 'IDENTIFIANT'
          # Champ vide (int (10))
          @identifiant = value                                 

        when 'AUTORISATION'
          # Numéro d'autorisation délivré par le centre d'autorisation de la banque du commerçant si le paiement est accepté (varchar (10))
          @autorisation = value 

        when 'CODEREPONSE'
          # Code réponse concernant l'état de la réponse traité, opération acceptée ou refusée (varchar (10))
          @codereponse = value 

        when 'REFABONNE'
          # Numéro d'abonné (user) contenu dans la trame question (varchar (250))
          @refabonne = value 

        when 'PORTEUR'
          # Numéro porteur partiel (n° carte crypté), Identique à la trame question (varchar (19))
          @porteur = value 

        when 'COMMENTAIRE'
          # Messages divers pour information (varchar(100))
          @commentaire = value 

        when 'PAYS'
          # Code Pays du porteur de la carte (format ISO 3166)
          @pays = value 

        when 'TYPECARTE'
          # Type de carte utilisé (varchar(10))
          @typecart = value 

        when 'SHA-1'
          # Empreinte SHA-1 de la carte utilisée
          @sha1 = value 

        when 'STATUS'
          # Etat de la transaction, retourné uniquement avec une question type 17 (=consultation) (varchar (16)) 
          @status = value 

        when 'REMISE'
          # Identifiant Paybox de la remise collectée (uniquement en consultation type 17), (int (9))
          @remise = value 
        end
      end

    end
  end
end
