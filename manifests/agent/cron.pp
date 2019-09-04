define puppet::agent::cron(
                            $server     = $name,
                            $ensure     = 'present', # @param cron_ensure Whether the cronjob should be present or not. (default: present)
                            $hour       = '*',
                            $minute     = '*/30',
                            $month      = undef,
                            $monthday   = undef,
                            $weekday    = undef,
                            $masterport = '8140',
                            $no_op      = false,
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
