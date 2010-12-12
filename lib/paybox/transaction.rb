module Paybox
  class Transaction
    attr_accessor :numtrans, :numappel, :numquestion, :site
    attr_accessor :rang, :identifiant, :autorisation, :codereponse
    attr_accessor :refabonne, :porteur, :commentaire, :pays
    attr_accessor :typecarte, :sha1, :status, :remise
  end
end
