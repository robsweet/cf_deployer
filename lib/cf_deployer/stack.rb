module CfDeployer
  class ResourceNotInReadyState < ApplicationError
  end

  class Stack
    SUCCESS_STATS = [:create_complete, :update_complete, :update_rollback_complete, :delete_complete]
    READY_STATS = SUCCESS_STATS - [:delete_complete]
    FAILED_STATS = [:create_failed, :update_failed, :delete_failed]
    MAX_TEMPLATE_BYTES = 51_200

    def initialize(stack_name, component, context)
      @stack_name = stack_name
      @context = context
      @component = component
      @cf_driver = context[:cf_driver] || CfDeployer::Driver::CloudFormation.new(@context[:settings][:platform], stack_name)
    end

    def deploy
      config_dir = @context[:config_dir]
      template = CfDeployer::ConfigLoader.component_json(@component, @context)
      template = JSON.minify( template ) if template.bytesize > MAX_TEMPLATE_BYTES
      raise ApplicationError.new("CloudFormation template is > #{MAX_TEMPLATE_BYTES} bytes") if template.bytesize > MAX_TEMPLATE_BYTES

      capabilities = @context[:capabilities] || []
      notify = @context[:notify] || []
      tags = @context[:tags] || {}
      params = to_str(@context[:inputs].select{|key, value| @context[:defined_parameters].keys.include?(key)})
      CfDeployer::Driver::DryRun.guard "Skipping deploy" do
        exists? ? update_stack(template, params, capabilities, tags) : create_stack(template, params, capabilities, tags, notify)
      end
    end

    def outputs
      return {} unless ready?
      @cf_driver.outputs
    end

    def parameters
      return {} unless ready?
      @cf_driver.parameters
    end

    def output key
      begin
        @cf_driver.query_output(key) || (raise ApplicationError.new("'#{key}' is empty from stack #{name} output"))
      rescue AWS::CloudFormation::Errors::ValidationError => e
        raise ResourceNotInReadyState.new("Resource stack not in ready state yet, perhaps you should provision it first?")
      end
    end

    def delete
      if exists?
        CfDeployer::Driver::DryRun.guard "Skipping delete" do
          Log.info "deleting stack #{@stack_name}"
          @cf_driver.delete_stack
          wait_for_stack_to_delete
        end
      end
    end

    def exists?
      @cf_driver.stack_exists?
    end

    def ready?
      READY_STATS.include? @cf_driver.stack_status
    end

    def status
      if exists?
        ready? ? :ready : :exists
      else
        :does_not_exist
      end
    end

    def resource_statuses
      AWS.memoize do
        resources = @cf_driver.resource_statuses.merge( { :asg_instances => {}, :instances => {} } )
        if resources[@cf_driver.asg_type_name]
          resources[@cf_driver.asg_type_name].keys.each do |asg_name|
            resources[:asg_instances][asg_name] = CfDeployer::Driver::AutoScalingGroup.new(@context[:settings][:platform], asg_name).instance_statuses
          end
        end
        if resources[@cf_driver.instance_type_name]
          resources[@cf_driver.instance_type_name].keys.each do |instance_id|
            resources[:instances][instance_id] = CfDeployer::Driver::Instance.new(@context[:settings][:platform], instance_id).status
          end
        end
        resources
      end
    end

    def name
      @stack_name
    end

    def template
      @cf_driver.template
    end

    private

    def to_str(hash)
      hash.each { |k,v| hash[k] = v.to_s }
    end

    def update_stack(template, params, capabilities, tags)
      Log.info "Updating stack #{@stack_name}..."
      @cf_driver.update_stack template,
                              :capabilities => capabilities,
                              :parameters => params
      wait_for_stack_op_terminate
    end

    def create_stack(template, params, capabilities, tags, notify)
      Log.info "Creating stack #{@stack_name}..."
      @cf_driver.create_stack template,
                              :disable_rollback => true,
                              :capabilities => capabilities,
                              :notify => notify,
                              :tags => @cf_driver.reformat_tags(tags),
                              :parameters => params
      wait_for_stack_op_terminate
    end

    def stack_status
      @cf_driver.stack_status
    end

    def wait_for_stack_op_terminate
      stats = stack_status
      while !SUCCESS_STATS.include?(stats)
        sleep 15
        stats = stack_status
        raise ApplicationError.new("Resource stack update failed!") if FAILED_STATS.include? stats
        Log.info "current status: #{stack_status}"
      end
    end

    def wait_for_stack_to_delete
      Timeout::timeout(900){
        while exists?
          begin
            Log.info "current status: #{stack_status}"
            sleep 15
          rescue AWS::CloudFormation::Errors::ValidationError => e
            if e.message =~ /does not exist/
              break # This is what we wanted anyways
            else
              raise e
            end
          end
        end
      }
    end

  end
end
