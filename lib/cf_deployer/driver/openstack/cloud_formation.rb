module CfDeployer
  module Driver
    module Openstack
      class CloudFormation

        def initialize stack_name
          @stack_name = stack_name
        end

        def stack_exists?
          !heat_stack.nil?
        end

        def create_stack template, opts
          CfDeployer::Driver::DryRun.guard "Skipping create_stack" do
            OpenStack::Heat::Stack.create @stack_name, template, opts         ## Fix
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
          heat_stack.outputs.inject({}) do |memo, o|
            memo[o['output_key']] = o['output_value']
            memo
          end
        end

        def parameters
          heat_stack.parameters
        end

        def query_output key
          output = outputs.find { |o| o.key == key }
          output && output.value
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
          heat_stack.resource_summaries.each do |rs|
            resources[rs[:resource_type]] ||= {}
            resources[rs[:resource_type]][rs[:physical_resource_id]] = rs[:resource_status]
          end
          resources
        end

        def template
          heat_stack.template
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