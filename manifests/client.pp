class puppet::client(
											$puppetmaster          = 'puppetmaster',
											$puppetmasterport      = '8140',
											$pluginsync            = true,
											$waitforcert           = 30,
											$showdiff              = true,
											$ensure                = 'installed',
											$daemon_status         = 'running',
											$service_enable        = true,
											$autorestart           = $puppet::params::client_autorestart_default,
											$report                = true,
											$srcdir                = '/usr/local/src',
											$manage_package        = $puppet::params::manage_package_default,
											$log                   = '/var/log/puppet/puppet.log',
											$logdir                = '/var/log/puppet',
											$logrotate_rotate      = '15',
											$logrotate_maxsize     = '100M',
											$install_nagios_checks = true,
											$nagios_check_basedir  = '/usr/local/bin',
										) inherits puppet::params {

	validate_bool($pluginsync)
	validate_bool($autorestart)

	validate_re($ensure, [ '^installed$', '^latest$' ], "Not a valid package status: ${ensure}")
	validate_re($daemon_status, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${ensure}")

	Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

	if($manage_package)
	{
		if($puppet::params::puppet_install_supported==false)
    {
      fail("Installation unsupported on ${::operatingsystem} ${::operatingsystemrelease}")
    }

		package { 'puppet':
			ensure  => $ensure,
			#require => Class['puppet::puppetlabsrepo'],
			before  => Exec['mkdir_logpuppet'],
		}

		if($puppet::puppetlabsrepo::enable_puppetlabs_repo)
		{
			Package['puppet'] {
				require => Class['puppet::puppetlabsrepo'],
			}
		}
	}

	file { $defaultsfile:
		ensure  => present,
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		require => Exec['mkdir_logpuppet'],
		notify  => Service["puppet"],
		before  => Service["puppet"],
		content => template("${module_name}/${defaultstemplate}"),
	}

	exec { 'mkdir_logpuppet':
		command => '/bin/mkdir -p /var/log/puppet',
		creates => '/var/log/puppet',
	}

	concat::fragment{ 'puppetconf agent':
		target  => $puppet::params::puppetconf,
		order   => '01',
		content => template("${module_name}/puppetconf_agent.erb"),
		before  => Service['puppet'],
		notify  => Service['puppet'],
	}

	service { 'puppet':
		enable  => $service_enable,
		ensure  => $daemon_status,
		require => Class['puppet'],
	}

	if($autorestart) and ($daemon_status=='running')
	{
		if(defined(Class['monit']))
		{
			monit::checkpid { 'puppetd':
				pid        => '/var/run/puppet/agent.pid',
				initscript => '/etc/init.d/puppet',
			}
		}
	}

	if(defined(Class['logrotate']))
	{
		logrotate::logs { 'puppet-client':
			log          => $log,
			compress     => true,
			copytruncate => true,
			frequency    => 'daily',
			rotate       => $logrotate_rotate,
			missingok    => true,
			size         => $logrotate_maxsize,
		}
	}

	if($install_nagios_checks)
	{
		file { "${nagios_check_basedir}/check_last_puppet_run":
			ensure  => 'present',
			owner   => 'root',
			group   => 'root',
			mode    => '0755',
			content => file("${module_name}/nagios/check_last_puppet_run.sh"),
		}
	}

}
