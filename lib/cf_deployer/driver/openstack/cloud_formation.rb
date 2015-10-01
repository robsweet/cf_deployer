module CfDeployer
  module Driver
    module Openstack
      class CloudFormation

        def initialize stack_name
          CfDeployer::Driver::Openstack::Connection.ensure_connected
          @stack_name = stack_name
        end

        def asg_type_name
          'OS::Heat::AutoScalingGroup'
        end

        def instance_type_name
          'OS::Nova::Server'
        end

        def stack_exists?
          !heat_stack.nil?
        end

        def create_stack template, opts
          CfDeployer::Driver::DryRun.guard "Skipping create_stack" do
            os_stack_opts = { :stack_name       => @stack_name,
                              :template         => JSON.parse(template),
                              :tags             => opts[:tags],
                              :parameters       => opts[:parameters],
                              :disable_rollback => opts[:disable_rollback]
                            }
            OpenStack::Heat::Stack.create os_stack_opts
          end
        end

        def update_stack template, opts
          begin
            CfDeployer::Driver::DryRun.guard "Skipping update_stack" do
              heat_stack.update opts.merge(:template => template)             ## Fix
            end
          rescue AWS::CloudFormation::Errors::ValidationError => e            ## Fix
            if e.message =~ /No updates are to be performed/
              Log.info e.message
            else
              raise
            end
          end
        end

        def stack_status
          heat_stack.status.downcase.to_sym
        end

        def outputs
          @outputs ||= heat_stack.outputs.inject({}) do |memo, o|
            memo[o['output_key']] = o['output_value']
            memo
          end
        end

        def parameters
          heat_stack.parameters
        end

        def query_output key
          outputs[key]
        end

        def delete_stack
          if stack_exists?
            CfDeployer::Driver::DryRun.guard "Skipping create_stack" do
              heat_stack.delete
            end
          else
            Log.info "Stack #{@stack_name} does not exist!"
          end
        end

        def resource_statuses
          resources = {}
          heat_stack.resources.each do |rs|
            resources[rs['resource_type']] ||= {}
            resources[rs['resource_type']][rs['physical_resource_id']] = rs['resource_status']
          end
          resources
        end

        def template
          heat_stack.template
        end

        def reformat_tags tags_hash
          tags_hash.keys.map { |key| "#{key.to_s}=#{tags_hash[key].to_s}" }.join ','
        end

        private

        def heat
          OpenStack::Heat::Stack.new
        end

        def heat_stack
          OpenStack::Heat::Stack.stacks.detect{ |stack| stack.name == @stack_name }
        end

      end
    end
  end
end
