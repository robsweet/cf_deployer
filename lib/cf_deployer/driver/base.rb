module CfDeployer
  module Driver
    class Base
      def self.klass platform
        klass_parts = self.to_s.split('::')
        Kernel.const_get( klass_parts[0] ).const_get( klass_parts[1] ).const_get(platform).const_get( klass_parts[2] )
      end
    end
  end
end

module CfDeployer
  module Driver
    class AutoScalingGroup < CfDeployer::Driver::Base
      def self.new platform, name, region, timeout = CfDeployer::Defaults::Timeout
        klass(platform).new name, region, timeout
      end
    end
  end
end

module CfDeployer
  module Driver
    class CloudFormation < CfDeployer::Driver::Base

      def self.new platform, stack_name, region
        klass(platform).new stack_name, region
      end
    end
  end
end

module CfDeployer
  module Driver
    class ELB < CfDeployer::Driver::Base
      def self.new platform, region
        klass(platform).new region
      end
    end
  end
end

module CfDeployer
  module Driver
    class Instance < CfDeployer::Driver::Base
      GOOD_STATUSES = [ :running, :pending, 'ACTIVE', 'INITIALIZED' ]

      def self.new platform, instance_obj_or_id, region
        klass(platform).new instance_obj_or_id, region
      end
    end
  end
end
