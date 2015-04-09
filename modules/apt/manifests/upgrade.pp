class apt::upgrade (
    $dist_upgrade = $::apt::params::dist_upgrade
) {

    validate_bool($dist_upgrade)
    if $dist_upgrade {
        Exec <| title=='apt-dist-upgrade' |> {
            refreshonly => false
        }
    }

    # Run apt-get update only if needed
    exec { 'apt-upgrade':
        command   => 'apt-get -y upgrade',
        onlyif    => 'test `apt-get -s -o Debug::NoLocking=true upgrade | grep -c ^Inst` != 0',
        logoutput => 'on_failure'
    }

    exec { 'apt-dist-upgrade':
        command     => 'apt-get -y dist-upgrade',
        onlyif      => 'test `apt-get -s -o Debug::NoLocking=true dist-upgrade | grep -c ^Inst` != 0',
        logoutput   => 'on_failure',
        refreshonly => true
    }

    # Dependencies
    Exec['apt-update'] ->
    Exec['apt-upgrade'] ->
    Exec['apt-dist-upgrade']
}
