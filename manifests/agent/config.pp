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
