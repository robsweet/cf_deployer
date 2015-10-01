module CfDeployer
  module Driver
    module Openstack
      class Instance

        def initialize instance_obj_or_id
          CfDeployer::Driver::Openstack::Connection.ensure_connected

          if instance_obj_or_id.is_a?(String)
            @id = instance_obj_or_id
          else
            @instance_obj = instance_obj_or_id
          end
        end

        def status
          instance_info = { }
          [:status, :image].each do |stat|
            instance_info[stat] = server.send(stat)
          end
          instance_info[:public_ip_address] = public_ip_address
          instance_info[:private_ip_address] = private_ip_address
          instance_info[:key_pair] = server.key_name
          instance_info
        end

        def public_ip_address
          pub = server.addresses.detect { |address| address.label == 'public' }
          pub ? pub.address : nil
        end

        def private_ip_address
          priv = server.addresses.detect { |address| address.label == 'private' }
          priv ? priv.address : nil
        end

        def server
          @instance_obj ||= CfDeployer::Driver::Openstack::Connection.nova_conn.get_server @id
        end
      end
    end
  end
end
