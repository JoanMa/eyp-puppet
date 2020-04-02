class puppet::agent::install inherits puppet::agent {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($puppet::agent::manage_package)
  {
    include ::puppet::puppetlabsrepo

    package { $puppet::params::agent_package_name:
      ensure  => $puppet::agent::package_ensure,
      require => Class['::puppet::puppetlabsrepo'],
    }
  }

  exec { 'mkdir logpuppet':
    command => '/bin/mkdir -p /var/log/puppet',
    creates => '/var/log/puppet',
  }

  if($puppet::agent::install_nagios_checks)
  {
    file { "${puppet::agent::nagios_check_basedir}/check_last_puppet_run":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => file("${module_name}/check_last_puppet_run.sh"),
    }

    file { "${puppet::agent::nagios_check_basedir}/puppetlr":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => file("${module_name}/puppet_last_run.sh"),
    }
  }

  if($puppet::agent::install_snmpd_checks)
  {
    if(defined(Class['snmpd']))
    {
      snmpd::extend { 'puppetlr':
        script      => "${puppet::agent::nagios_check_basedir}/puppetlr",
        description => 'puppet last run difference',
      }
    }
  }
}
