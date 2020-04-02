class { 'snmpd':
  add_default_acls => false,
}

class { 'snmpd::loadavg': }

snmpd::v3user { 'v3testuser':
  authpass => '1234567890',
  encpass  => '1234567890',
}

class { 'puppet::agent':
  puppetmaster     => 'lolmaster',
  puppetmasterport => '1234',
}

# snmpwalk -v3  -l authPriv -u v3testuser -a SHA -A "1234567890"  -x AES -X "1234567890" 127.0.0.1 .1 | grep "puppetlr"
