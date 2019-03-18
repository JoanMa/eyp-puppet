
_osfamily               = fact('osfamily')
_operatingsystem        = fact('operatingsystem')
_operatingsystemrelease = fact('operatingsystemrelease').to_f

case _osfamily
when 'RedHat'
  $packagename  = ''

when 'Debian'
  $packagename = ''

else
  $packagename = '-_-'

end
