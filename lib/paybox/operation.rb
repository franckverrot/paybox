module Paybox
  module Operation
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations

      # Payment's details
      attr_accessor :operation #:operation => ":operation . The code of requested operation to be done", 
      attr_accessor :amount    #:amount => ":amount . The amount of the transaction", 
      attr_accessor :user_id   #:user_id => "user_id . The id of your user in your own Database", 
      attr_accessor :card_nbr  #:card_nbr => ":card_nbr . The crypted partial card number in your Database", 
      attr_accessor :expire    #:expire => ":expire . The expiration date of the card",
      attr_accessor :cvv2      #:cvv2 => ":cvv2 . The CVV2 parameter you should have stored in your DB",
      attr_accessor :numtrans  #:numtrans => ":numtrans . The previous transaction number"   


      validates :operation, :amount, :user_id, :card_nbr, :expire, :cvv2, :presence  =>  true
      validates :card_nbr, :credit_card => { :type => :any }

      # WARNING :numtrans parameter IS REQUIRED only for operations 00002, 00005, 00013, 00017, 00052, 00055 
      NUM_TRANS_REQUIRED_ARRAY = ['00002', '00005', '000013', '00017', '00052', '00055']
      validates :numtrans, :presence => true, :if => Proc.new { |obj| NUM_TRANS_REQUIRED_ARRAY.include?(obj.operation) }
    end
  end
end
