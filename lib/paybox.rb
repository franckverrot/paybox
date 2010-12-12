require 'active_support'
require 'active_support/all'
require 'active_model'
require 'active_model/validations'
require 'httparty'

module Paybox
  extend ActiveSupport::Autoload
  autoload :Paybox
  autoload :Transaction
end
