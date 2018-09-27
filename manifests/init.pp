class puppet(
              $srcdir                 = '/usr/local/src',
              $basemodulepath         = '/etc/puppet/modules:/usr/share/puppet/modules',
              $enable_puppetlabs_repo =  true,
            ) inherits puppet::params {

  if($enable_puppetlabs_repo)
  {
    class { 'puppet::puppetlabsrepo':
      enable_puppetlabs_repo => $enable_puppetlabs_repo,
      srcdir                 => $srcdir,
    }
  }

  exec { "mkdir p puppet ${srcdir}":
    command => "mkdir -p ${srcdir}",
    creates => $srcdir,
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
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
}
