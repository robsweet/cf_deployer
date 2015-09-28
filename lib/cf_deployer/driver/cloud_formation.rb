require 'pp'
module CfDeployer
  module Driver
    class CloudFormation

      def self.new platform, stack_name
        klass = Kernel.const_get('CfDeployer').const_get('Driver').const_get(platform).const_get('CloudFormation')
        klass.new stack_name
      end
    end
  end
end