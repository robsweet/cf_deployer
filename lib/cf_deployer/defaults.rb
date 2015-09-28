module CfDeployer
  module Defaults
    ELBName = 'ELBName'
    AutoScalingGroupName = 'AutoScalingGroupName'
    Timeout = 900
    DNSDriver = 'CfDeployer::Driver::Route53'
    RaiseErrorForUnusedInputs = false
    KeepPreviousStack = true
    # Platform = 'AWS'
    Platform = 'Openstack'
  end
end
