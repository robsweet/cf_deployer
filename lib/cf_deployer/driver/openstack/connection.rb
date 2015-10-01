require 'net/http'

# module Net
#   class HTTP
#     alias_method '__initialize__', 'initialize'

#     def initialize(*args,&block)
#       __initialize__(*args, &block)
#     ensure
#       @debug_output = $stderr ### if ENV['HTTP_DEBUG']
#     end
#   end
# end

module CfDeployer
  module Driver
    module Openstack
      class Connection

        class << self
          attr_accessor :nova_conn, :neutron_conn

          def ensure_connected
            creds = { :username    => "admin",
                      :api_key     => "osnodeCL3100",
                      :auth_url    => "http://10.201.10.12:35357/v2.0/",
                      :authtenant  => "demo"
                    }
            OpenStack::Heat::Connection.create  creds
            @nova_conn    = OpenStack::Connection.create creds.merge( :service_name => 'nova',    :service_type => 'compute' )
            @neutron_conn = OpenStack::Connection.create creds.merge( :service_name => 'neutron', :service_type => 'network' )
          end

        end

      end
    end
  end
end