class puppet::agent::service inherits puppet::agent {

  $is_docker_container_var=getvar('::eyp_docker_iscontainer')
  $is_docker_container=str2bool($is_docker_container_var)

  if( $is_docker_container==false or
      $puppet::agent::manage_docker_service)
  {
    if($puppet::agent::manage_service)
    {
      service { $puppet::params::agent_service_name:
        ensure => $puppet::agent::service_ensure,
        enable => $puppet::agent::service_enable,
      }
    }
  }

}
