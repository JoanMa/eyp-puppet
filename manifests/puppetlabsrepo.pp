class puppet::puppetlabsrepo(
                              $enable_puppetlabs_repo = true,
                              $srcdir                 = $puppet::srcdir,
                            ) inherits puppet {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($enable_puppetlabs_repo)
  {
    if($puppet::params::puppetlabs_repo!=undef)
    {
      download { 'puppetlabs repo puppet':
        url     => $puppet::params::puppetlabs_repo,
        creates => "${srcdir}/puppetlabs_repo.${puppet::params::package_provider}",
        require => Class['::puppet'],
      }

      package { $puppet::params::puppetlabs_package:
        ensure   => 'installed',
        provider => $puppet::params::package_provider,
        source   => "${srcdir}/puppetlabs_repo.${puppet::params::package_provider}",
        require  => Download['puppetlabs repo puppet'],
      }
    }
  }
}
