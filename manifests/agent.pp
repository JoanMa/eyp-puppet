class puppet::agent(
                      $puppetmaster          = 'puppetmaster',
                      $puppetmasterport      = '8140',
                      $srcdir                = '/usr/local/src',
                      $waitforcert           = 30,
                      $showdiff              = true,
                      $package_ensure        = 'installed',
                      $service_ensure        = 'running',
                      $service_enable        = true,
                      $manage_service        = true,
                      $manage_package        = $puppet::params::manage_package_default,
                      $log                   = '/var/log/puppet/puppet.log',
                      $logdir                = '/var/log/puppet',
                      $logrotate_rotate      = '15',
                      $logrotate_maxsize     = '100M',
                      $install_nagios_checks = true,
                      $nagios_check_basedir  = '/usr/local/bin',
                      $install_snmpd_checks  = true,
                      $manage_config_file    = true,
                      $puppetenv             = undef,
                      $runinterval           = undef,
                      $no_op                 = false,
                    ) inherits puppet::params {

  include ::puppet

  Class['::puppet'] ->
  class { '::puppet::agent::install': } ->
  class { '::puppet::agent::config': } ~>
  class { '::puppet::agent::service': } ->
  Class['::puppet::agent']

}
