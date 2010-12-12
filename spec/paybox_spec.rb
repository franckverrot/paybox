require File.join(File.dirname(__FILE__), 'spec_helper.rb')

TEST_DATA = {
  :user_id  => 1,
  :card_nbr => 'foobar',
  :expire   => '1012',
  :cvv2     => '123'
}

describe "Paybox" do
  before(:each) do
  end

  it "initializes itself and post the data to the GW" do
    paybox = Paybox::Paybox.new(
      :operation => '00057',
      :amount    => 1000,
      :user_id   => TEST_DATA[:user_id],
      :card_nbr  => TEST_DATA[:card_nbr],
      :expire    => TEST_DATA[:expire],
      :cvv2      => TEST_DATA[:cvv2]
    )

    response = paybox.authorize

    response.codereponse.should == '00000' #=> Cool, successful request
    # response.commentaire = "PAYBOX : Numéro de porteur invalide" #=> Oooops, invalid card number given

  end
end
