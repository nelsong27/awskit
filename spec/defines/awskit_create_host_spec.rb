require 'spec_helper'

describe 'awskit::create_host' do
  let(:title) { 'my-instance-name' }
  let(:facts) { RSpec.configuration.default_facts }
  let(:params) do
    {
      'ami'           => 'my_ami',
      'instance_type' => 'my_instance_type',
    }
  end

  it { is_expected.to compile }

  it {
    is_expected.to contain_ec2_instance(title).with(
      'image_id'      => params['ami'],
      'instance_type' => params['instance_type'],
    )
  }

  context 'without explicitly specified public ip' do
    it { is_expected.to contain_ec2_elastic_ip('2.3.4.5') } # from hiera awskit::hostconfig.my_host.public_ip
  end

  context 'with explicitly specified public ip' do
    let(:params) do
      super().merge('public_ip' => '5.6.7.8')
    end

    it { is_expected.to contain_ec2_elastic_ip('5.6.7.8') }
  end

  context 'without explicitly specified security groups' do
    it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-agent") }
    it {
      is_expected.to contain_ec2_instance(title).with(
        'security_groups' => "#{facts['user']}-awskit-agent",
      )
    }
  end

  context 'with explicitly specified security groups' do
    let(:pre_condition) { "ec2_securitygroup { 'my_sg': }" }
    let(:params) do
      super().merge('security_groups' => 'my_sg')
    end

    it { is_expected.to contain_ec2_securitygroup("#{facts['user']}-awskit-agent") }
    it {
      is_expected.to contain_ec2_instance(title).with(
        'security_groups' => 'my_sg',
      )
    }
  end
end
