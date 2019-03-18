require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'puppet class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'puppet::agent':
        puppetmaster     => 'lolmaster',
        puppetmasterport => '1234',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    #/etc/puppetlabs/puppet/puppet.conf
    # server = <%= @puppetmaster %>
    # masterport = <%= @puppetmasterport %>
    describe file('/etc/puppetlabs/puppet/puppet.conf') do
      it { should be_file }
      its(:content) { should match 'puppet managed file' }
      its(:content) { should match 'server = lolmaster' }
      its(:content) { should match 'masterport = 1234' }
    end

    it "env production" do
      expect(shell("puppet config print environment | grep production").exit_code).to be_zero
    end

    it 'tstenv should work with no errors' do
      pp = <<-EOF

      class { 'puppet::agent':
        puppetmaster       => 'lolmaster',
        puppetmasterport   => '1234',
        puppetenv          => 'tstenv',
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
    end

    describe file('/etc/puppetlabs/puppet/puppet.conf') do
      it { should be_file }
      its(:content) { should match 'puppet managed file' }
      its(:content) { should match 'server = lolmaster' }
      its(:content) { should match 'masterport = 1234' }
      its(:content) { should match 'environment=tstenv' }
    end

    it "puppet configured env" do
      expect(shell("puppet config print environment").exit_code).to be_zero
    end

    it "env tst_env" do
      expect(shell("puppet config print environment | grep tstenv").exit_code).to be_zero
    end

  end
end
