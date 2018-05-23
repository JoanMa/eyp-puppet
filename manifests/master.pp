class puppet::master(
                      $certname,
                      $dns_alt_names      = undef,
                      $puppetmasterport   = '8140',
                      $report_to_logstash = true,
                      $manage_service     = true,
                      $masterhttplog      = '/dev/null',
                      $autosign           = true,
                      $pluginsync         = true,
                      $errorlog           = '/dev/null',
                      $combinedlog        = '/dev/null',
                      $ca_ttl             = '1000y',
                      $logstash_host      = '127.0.0.1',
                      $logstash_port      = '5959',
                      $report             = true,
                      $puppetserver_mem   = '2g',
                      $vardir             = $puppet::params::vardir_default,
                      $logdir             = $puppet::params::logdir_default,
                      $rundir             = $puppet::params::rundir_default,
                      $pidfile            = $puppet::params::pidfile_default,
                      $codedir            = $puppet::params::codedir_default,
                    ) inherits puppet::params {

  #masterless only

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($manage_service)
  {
    $serviceinstance=Service['apache2']
  }

  if($dns_alt_names!=undef)
  {
    validate_array($dns_alt_names)
  }

  package { $puppet::params::puppet_master_packages:
    ensure  => 'installed',
    require => Class['puppet::puppetlabsrepo'],
  }

  case $::osfamily
  {
    'redhat':
    {
      fail('TODO')
    }
    'Debian':
    {
      case $::operatingsystem
      {
        'Ubuntu':
        {
          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              #require puppet::puppetlabsrepo

              file { '/etc/default/puppetmaster':
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template("${module_name}/master/debian/puppetmaster.erb"),
                require => Package[$puppet::params::puppet_master_packages],
                notify  => $serviceinstance,
              }

              concat::fragment{ 'puppetconf master':
                target  => $puppet::params::puppetconf,
                order   => '02',
                content => template("${module_name}/puppetconf_master.erb"),
                require => Package[$puppet::params::puppet_master_packages],
                notify  => $serviceinstance,
              }

              # /etc/apache2/sites-available/puppetmaster.conf
              file { '/etc/apache2/sites-available/puppetmaster.conf':
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template("${module_name}/master/apache/vhost_puppetmaster.erb"),
                require => Package[$puppet::params::puppet_master_packages],
                notify  => $serviceinstance,
              }

              exec { "build CA ${certname}":
                command => "puppet cert --generate ${certname}",
                creates => "/var/lib/puppet/ssl/certs/${certname}.pem",
                require => Package[$puppet::params::puppet_master_packages],
              }

              file { '/etc/apache2/sites-enabled/puppetmaster.conf':
                ensure  => 'link',
                target  => '/etc/apache2/sites-available/puppetmaster.conf',
                require => File['/etc/apache2/sites-available/puppetmaster.conf'],
                notify  => $serviceinstance,
              }

              file { '/etc/puppet/logstash.yaml':
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0444',
                content => template("${module_name}/logstash_reporter/logstash.yaml.erb"),
              }

              if($manage_service)
              {
                service { 'apache2':
                  ensure  => 'running',
                  enable  => true,
                  require =>  [
                                File[
                                      [
                                        '/etc/apache2/sites-enabled/puppetmaster.conf',
                                        '/etc/apache2/sites-available/puppetmaster.conf',
                                        '/etc/default/puppetmaster',
                                        '/etc/puppet/logstash.yaml'
                                      ]
                                    ],
                                Exec["build CA ${certname}"],
                                Concat['/etc/puppet/puppet.conf'],
                              ],
                }
              }
            }
            /^16.*$/:
            {
              file { '/etc/default/puppetserver':
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template("${module_name}/master/debian/puppetmaster.erb"),
                require => Package[$puppet::params::puppet_master_packages],
                notify  => $serviceinstance,
              }

              fail('unimplemented')
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}") }
          }
        }
        default: { fail('unsupported') }
      }
    }
    default: { fail('unsupported') }
  }
}
