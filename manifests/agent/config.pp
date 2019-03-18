#
class puppet::agent::config inherits puppet::agent {

  if($puppet::agent::manage_config_file)
  {
    file { $puppet::params::defaultsfile:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/${puppet::params::defaultstemplate}"),
    }

    concat { $puppet::params::puppetconf:
      ensure => 'present',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }

    concat::fragment { 'puppetconf main':
      target  => $puppet::params::puppetconf,
      order   => '00',
      content => template("${module_name}/puppetconf_main.erb"),
    }

    concat::fragment{ 'puppetconf agent':
      target  => $puppet::params::puppetconf,
      order   => '01',
      content => template("${module_name}/puppetconf_agent.erb"),
    }
  }

  if(defined(Class['logrotate']))
  {
    logrotate::logs { 'puppet-client':
      log          => $puppet::agent::log,
      compress     => true,
      copytruncate => true,
      frequency    => 'daily',
      rotate       => $puppet::agent::logrotate_rotate,
      missingok    => true,
      size         => $puppet::agent::logrotate_maxsize,
    }
  }
}
