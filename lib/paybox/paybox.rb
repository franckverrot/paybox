module Paybox
  class Paybox
    include Configuration    # Class-level configuration like site, rang, cle
    include Gateway          # Gateway technical infrastructure
    include Operation        # Internal validations

    # Internal result when the object issues a call to Paybox
    attr_accessor :transaction

    def initialize(args)
      args.each_pair { |k,v| send("#{k}=",v) }
    end

    def process
      return false unless self.valid?

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

      current_date = Time.now

      data = {
        :SITE         => self.class.site,
        :RANG         => self.class.rang,
        :CLE          => self.class.cle,

        :DATEQ        => current_date.strftime('%d%m%Y%H%M%S'),
        :NUMQUESTION  => current_date.to_i,
        :TYPE         => self.operation,
        :MONTANT      => self.amount,
        :REFERENCE    => "test",
        :REFABONNE    => self.user_id,
        :VERSION      => '00104',
        :IDENTIFIANT  => '2',
        :DEVISE       => "978", #EURO
        :PORTEUR      => self.card_nbr,
        :DATEVAL      => self.expire,
        :CVV          => self.cvv2,
        :ACTIVITE     => "024",
        :ARCHIVAGE    => "Simplissime.fr",
        :DIFFERE      => "000",
        :NUMAPPEL     => "",
        :NUMTRANS     => self.numtrans,
        :AUTORISATION => "",
        :PAYS         => "FR"
      }

      response = _process data

      # Now we've got a response, let's parse it
      self.transaction = Transaction.new.tap do |trans|
        response.body.split('&').each do |parameter|
          parameter.strip!
          key = parameter.split('=').first
          value = Iconv.conv('utf-8', 'ISO-8859-1', parameter.split('=').last)

          begin
            #Transforms an attribute FIELD-BLAH into fieldblah
            trans.send("#{key.downcase.tr('-','')}=", value)
          rescue
            warn "The gem doesnt know about the resulting field #{key}"
            warn "Fill-in a ticket if you think this is not expected"
            return false
          end
        end
      end
      true
    end
  end
end
