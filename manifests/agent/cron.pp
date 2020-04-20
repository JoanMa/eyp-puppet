define puppet::agent::cron(
                            $server      = $name,
                            $ensure      = 'present',
                            $hour        = '*',
                            $minute      = '*/30',
                            $month       = undef,
                            $monthday    = undef,
                            $weekday     = undef,
                            $masterport  = '8140',
                            $no_op       = false,
                            $ssldir      = undef,
                            $description = undef,
                          ) {

  if defined($description)
  {
    $cron_description = $description
  }
  else
  {
    $cron_description = "cron puppet ${server} ${masterport}"
  }

  cron { $cron_description:
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
