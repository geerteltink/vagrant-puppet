class apt::upgrade {

    # Run apt-get update when asked for
    exec { 'apt-upgrade':
        command     => 'apt-get -y upgrade',
        logoutput   => 'on_failure'
    }

    Exec['apt-update'] -> Exec['apt-upgrade']
}
