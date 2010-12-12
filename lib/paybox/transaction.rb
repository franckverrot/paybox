module Paybox
  class Transaction
    attr_accessor :numtrans #'NUMTRANS'          #Numéro de la transaction créée (int (10))
    attr_accessor :numappel #'NUMAPPEL'          # Numéro de la requête gérée sur Paybox (int (10))
    attr_accessor :numquestion #'NUMQUESTION'          # Identifiant unique et sequentiel (un timestamp sur 10 chiffres )
    attr_accessor :site #'SITE'          # Numéro d'adhérent fourni par la banque (int (7))
    attr_accessor :rang #'RANG'          # Numéro de rang fourni par la banque du commerçant (int (2))
    attr_accessor :identifiant #'IDENTIFIANT'          # Champ vide (int (10))
    attr_accessor :autorisation #'AUTORISATION'          # Numéro d'autorisation délivré par le centre d'autorisation de la banque du commerçant si le paiement est accepté (varchar (10))
    attr_accessor :codereponse #'CODEREPONSE'          # Code réponse concernant l'état de la réponse traité, opération acceptée ou refusée (varchar (10))
    attr_accessor :refabonne #'REFABONNE'          # Numéro d'abonné (user) contenu dans la trame question (varchar (250))
    attr_accessor :porteur #'PORTEUR'          # Numéro porteur partiel (n° carte crypté), Identique à la trame question (varchar (19))
    attr_accessor :commentaire #'COMMENTAIRE'          # Messages divers pour information (varchar(100))
    attr_accessor :pays #'PAYS'          # Code Pays du porteur de la carte (format ISO 3166)
    attr_accessor :typecarte #'TYPECARTE'          # Type de carte utilisé (varchar(10))
    attr_accessor :sha1 #'SHA-1'          # Empreinte SHA-1 de la carte utilisée
    attr_accessor :status #'STATUS'          # Etat de la transaction, retourné uniquement avec une question type 17 (=consultation) (varchar (16)) 
    attr_accessor :remise #'REMISE'          # Identifiant Paybox de la remise collectée (uniquement en consultation type 17), (int (9))
  end
end
