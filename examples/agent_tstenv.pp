class { 'puppet::agent':
  puppetmaster     => 'lolmaster',
  puppetmasterport => '1234',
  puppetenv        => 'tstenv',
}
