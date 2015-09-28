module CfDeployer
  module Driver
    class AutoScalingGroup

      def self.new platform, name, timeout = CfDeployer::Defaults::Timeout
        klass = Kernel.const_get('CfDeployer').const_get('Driver').const_get(platform).const_get('AutoScalingGroup')
        klass.new name, timeout
      end
    end
  end
end
