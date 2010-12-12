require File.join(File.dirname(__FILE__), 'spec_helper.rb')

TEST_DATA = {
  :user_id  => 1,
  :card_nbr => '4111 1111 1111 1111',
  :expire   => '1012',
  :cvv2     => '123'
}

describe "Paybox" do
  before(:each) do
    Paybox::Paybox.configure do |configuration|
      configuration.site = '1999888'
      configuration.rang = '99'
      configuration.cle  = '1999888I'
    end
  end

  it "can be configured" do
    Paybox::Paybox.site.should == '1999888'
    Paybox::Paybox.rang.should == '99'
    Paybox::Paybox.cle.should  == '1999888I'
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

    paybox.process.should be(true)
    paybox.transaction.codereponse.should == '00000' #=> Cool, successful request
  end
end
