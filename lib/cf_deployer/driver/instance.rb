module CfDeployer
  module Driver
    class Instance

      GOOD_STATUSES = [ :running, :pending ]

      def self.new platform, instance_obj_or_id
        klass = Kernel.const_get('CfDeployer').const_get('Driver').const_get(platform).const_get('Instance')
        klass.new instance_obj_or_id
      end
    end
  end
end