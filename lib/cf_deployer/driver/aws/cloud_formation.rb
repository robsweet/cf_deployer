module CfDeployer
  module Driver
    module AWS
      class CloudFormation

        def initialize stack_name, region
          @stack_name = stack_name
          @region = region
        end

        def asg_type_name
          'AWS::AutoScaling::AutoScalingGroup'
        end

        def instance_type_name
          'AWS::EC2::Instance'
        end

        def stack_exists?
          aws_stack.exists?
        end

        def create_stack template, opts
          CfDeployer::Driver::DryRun.guard "Skipping create_stack" do
            cloud_formation.stacks.create @stack_name, template, opts
          end
        end

        def update_stack template, opts
          begin
            CfDeployer::Driver::DryRun.guard "Skipping update_stack" do
              aws_stack.update opts.merge(:template => template)
            end
          rescue ::AWS::CloudFormation::Errors::ValidationError => e
            if e.message =~ /No updates are to be performed/
              Log.info e.message
            else
              raise e
            end
          end
        end

        def stack_status
          aws_stack.status.downcase.to_sym
        end

        def outputs
          aws_stack.outputs.inject({}) do |memo, o|
            memo[o.key] = o.value
            memo
          end
        end

        def parameters
          aws_stack.parameters
        end

        def query_output key
          output = aws_stack.outputs.find { |o| o.key == key }
          output && output.value
        end

        def delete_stack
          if stack_exists?
            CfDeployer::Driver::DryRun.guard "Skipping create_stack" do
              aws_stack.delete
            end
          else
            Log.info "Stack #{@stack_name} does not exist!"
          end
        end

        def resource_statuses
          resources = {}
          aws_stack.resource_summaries.each do |rs|
            resources[rs[:resource_type]] ||= {}
            resources[rs[:resource_type]][rs[:physical_resource_id]] = rs[:resource_status]
          end
          resources
        end

        def template
          aws_stack.template
        end

        def reformat_tags tags_hash
          tags_hash.keys.map { |key| { 'Key' => key.to_s, 'Value' => tags_hash[key].to_s } }
        end

        private

        def cloud_formation
          ::AWS::CloudFormation.new :region => @region
        end

        def aws_stack
          cloud_formation.stacks[@stack_name]
        end

      end
    end
  end
end
