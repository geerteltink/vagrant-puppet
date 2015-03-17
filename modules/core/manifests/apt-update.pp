class core::apt-update {
  exec { 'apt-get update':
    command     => "apt-get update",
    path        => ['/usr/bin'],
    logoutput   => 'on_failure',
    timeout     => 300
  }

  exec { 'apt-get upgrade':
    command     => "/usr/bin/apt-get -y upgrade",
    logoutput   => 'on_failure',
    refreshonly => true,
    require => Exec['apt-get update']
  }
}
