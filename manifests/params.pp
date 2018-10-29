class puppet::params {

  $puppetlabs_package='puppet5-release'
  $agent_service_name='puppet'
  $agent_package_name='puppet-agent'

  case $::osfamily
  {
    'redhat':
    {
      $manage_package_default=true
      $defaultsfile='/etc/sysconfig/puppet'
      $defaultstemplate='sysconfig.erb'
      $package_provider='rpm'

      $puppetconf='/etc/puppetlabs/puppet//puppet.conf'

      case $::operatingsystemrelease
      {
        /^5.*$/:
        {
          $puppetlabs_repo='https://yum.puppet.com/puppet5/puppet5-release-el-5.noarch.rpm'
        }
        /^6.*$/:
        {
          $puppetlabs_repo='https://yum.puppet.com/puppet5/puppet5-release-el-6.noarch.rpm'
        }
        /^7.*$/:
        {
          $puppetlabs_repo='https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm'
        }
        default: { fail("Unsupported RHEL/CentOS version! - ${::operatingsystemrelease}")  }
      }
    }
    'Debian':
    {
      $manage_package_default=true
      $defaultsfile='/etc/default/puppet'
      $defaultstemplate='defaultpuppet.erb'
      $package_provider='dpkg'

      $puppetconf='/etc/puppetlabs/puppet/puppet.conf'

      case $::operatingsystem
      {
        'Ubuntu':
        {
        case $::operatingsystemrelease
        {
          /^14.*$/:
          {
            $puppetlabs_repo='https://apt.puppetlabs.com/puppet5-release-trusty.deb'
          }
          /^16.*$/:
          {
            $puppetlabs_repo='https://apt.puppetlabs.com/puppet5-release-xenial.deb'
          }
          /^18.*$/:
          {
            $puppetlabs_repo=undef
          }
          default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian': { fail('Unsupported')  }
        default: { fail('Unsupported Debian flavour!l')  }
      }
    }
    'Suse':
    {
      $manage_package_default=true
      $defaultsfile='/etc/sysconfig/puppet'
      $defaultstemplate='sysconfig.erb'
      $package_provider='rpm'

      $puppetconf='/etc/puppetlabs/puppet/puppet.conf'

      #rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-sles-12.noarch.rpm
      #zypper install puppet-agent
      
      case $::operatingsystem
      {
        'SLES':
        {
          case $::operatingsystemrelease
          {
            '11.3':
            {
              $puppetlabs_repo='https://yum.puppet.com/puppet5/puppet5-release-sles-11.noarch.rpm'
            }
            '12.3':
            {
              $puppetlabs_repo='https://yum.puppet.com/puppet5/puppet5-release-sles-12.noarch.rpm'
            }
            default: { fail("Unsupported SLES version! - ${::operatingsystemrelease}")  }
          }
        }
        default: { fail("Unsupported SuSE version! - ${::operatingsystemrelease}")  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
