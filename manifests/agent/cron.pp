define puppet::agent::cron(
                            $server     = $name,
                            $ensure     = 'present',
                            $hour       = '*',
                            $minute     = '*/30',
                            $month      = undef,
                            $monthday   = undef,
                            $weekday    = undef,
                            $masterport = '8140',
                            $no_op      = false,
                            $ssldir     = undef,
                          ) {

  cron { "cron puppet ${server} ${masterport}":
    ensure   => $ensure,
    command  => template("${module_name}/puppetcron.erb"),
    user     => 'root',
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
  }
}
