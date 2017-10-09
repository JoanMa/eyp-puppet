# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class puppet(
              $enable_puppetlabs_repo = $puppet::params::default_enable_puppetlabs_repo,
              $srcdir                 = '/usr/local/src',
              $basemodulepath         = '/etc/puppet/modules:/usr/share/puppet/modules',
            ) inherits puppet::params {

  if($enable_puppetlabs_repo)
	{
		class { 'puppet::puppetlabsrepo':
			enable_puppetlabs_repo => $enable_puppetlabs_repo,
      srcdir                 => $srcdir,
		}
	}

  concat { $puppet::params::puppetconf:
  	ensure => 'present',
  	owner  => 'root',
  	group  => 'root',
  	mode   => '0644',
  }

  concat::fragment{ 'puppetconf main':
  	target  => '/etc/puppet/puppet.conf',
  	order   => '00',
  	content => template("${module_name}/puppetconf_main.erb"),
  }
}
