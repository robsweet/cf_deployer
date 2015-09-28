module CfDeployer
  module Driver
    class ELB
      def self.new platform
        klass = Kernel.const_get('CfDeployer').const_get('Driver').const_get(platform).const_get('ELB')
        klass.new
      end
    end
  end
end