module CfDeployer
  module Driver
    module AWS
      class Instance

        def initialize instance_obj_or_id
          if instance_obj_or_id.is_a?(String)
            @id = instance_obj_or_id
          else
            @instance_obj = instance_obj_or_id
          end
        end

        def status
          instance_info = { }
          [:status, :public_ip_address, :private_ip_address, :image_id].each do |stat|
            instance_info[stat] = aws_instance.send(stat)
          end
          instance_info[:key_pair] = aws_instance.key_pair.name
          instance_info
        end

        def aws_instance
          @instance_obj ||= ::AWS::EC2.new.instances[@id]
        end
      end
    end
  end
end