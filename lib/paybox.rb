require 'active_support'
require 'active_support/all'
require 'active_model'
require 'active_model/validations'
require 'activevalidators'
require 'httparty'

module Paybox
  extend ActiveSupport::Autoload
  autoload :Paybox
  autoload :Transaction
  autoload :Configuration
  autoload :Gateway
  autoload :Operation
end
