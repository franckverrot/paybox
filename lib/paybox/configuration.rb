module Paybox
  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods
      attr_accessor :site, :rang, :cle
      def configure &block
        yield self
      end
    end
  end
end
