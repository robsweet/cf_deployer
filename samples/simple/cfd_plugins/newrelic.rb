require 'rest-client'

PlugMan.define :newrelic_notifier do
  author "Rob Sweet"
  version "1.0.0"
  params({ :description => "Notifies NewRelic of deployments" })
  extends({ :root => [:notify] })

  def recognized_settings
    [ :newrelic_api_key, :newrelic_app_name ]
  end

  def required_settings
    []
  end

  def notify component_hash
    @component_hash = component_hash
    if api_key
      # CfDeployer::Driver::DryRun.guard "Skipping NewRelic notification" do
        CfDeployer::Log.info "Notifying NewRelic of a deployment of '#{ami_id}' to '#{app_name}' with key '#{api_key}'"
        RestClient.post 'https://rpm.newrelic.com/deployments.xml', payload, headers
      # end
    else
      CfDeployer::Log.info "No value for setting newrelic_api_key.  Not doing deployment notification."
    end
  end

  ##  Private methods

  def settings
    @component_hash[:settings]
  end

  def inputs
    @component_hash[:inputs]
  end

  def ami_id
    image_id_key = inputs.keys.detect { |key| key =~ /ImageId/ }
    inputs[image_id_key]
  end

  def api_key
    settings[:newrelic_api_key]
  end

  def app_name
    settings[:newrelic_app_name] || "#{settings[:application]} #{settings[:component]} (#{settings[:environment]})"
  end

  def description
    "Deploying AMI #{ami_id} to #{settings[:region]}"
  end

  def payload
    { :deployment => { :app_name => app_name,
                       :revision => ami_id,
                       :description => description,
                       :user => 'CFDeployer'
                     }
    }
  end

  def headers
    { :'x-api-key' => api_key }
  end
end