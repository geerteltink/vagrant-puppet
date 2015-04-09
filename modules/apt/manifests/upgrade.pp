class apt::upgrade {

    # Run apt-get update only if needed
    exec { 'apt-upgrade':
        command   => 'apt-get -y upgrade',
        onlyif    => 'test `apt-get -s -o Debug::NoLocking=true upgrade | grep -c ^Inst` != 0',
        logoutput => 'on_failure'
    }

    # Dependencies
    Exec['apt-update'] ->
    Exec['apt-upgrade']
}
