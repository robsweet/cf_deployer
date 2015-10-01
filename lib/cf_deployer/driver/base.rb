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
      def self.new platform, name, timeout = CfDeployer::Defaults::Timeout
        klass(platform).new name, timeout
      end
    end
  end
end

module CfDeployer
  module Driver
    class CloudFormation < CfDeployer::Driver::Base

      def self.new platform, stack_name
        klass(platform).new stack_name
      end
    end
  end
end

module CfDeployer
  module Driver
    class ELB < CfDeployer::Driver::Base
      def self.new platform
        klass(platform).new
      end
    end
  end
end

module CfDeployer
  module Driver
    class Instance < CfDeployer::Driver::Base
      GOOD_STATUSES = [ :running, :pending, 'ACTIVE', 'INITIALIZED' ]

      def self.new platform, instance_obj_or_id
        klass(platform).new instance_obj_or_id
      end
    end
  end
end