class apt::upgrade (
    $dist_upgrade = $::apt::params::upgrade_dist,
    $autoremove   = $::apt::params::upgrade_remove
) {

    validate_bool($dist_upgrade)
    if $dist_upgrade {
        Exec <| title=='apt-dist-upgrade' |> {
            refreshonly => false
        }
    }

    validate_bool($autoremove)
    if $autoremove {
        Exec <| title=='apt-autoremove' |> {
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

    exec { 'apt-autoremove':
        command     => 'apt-get -y autoremove',
        onlyif      => 'test `apt-get -s -o Debug::NoLocking=true autoremove | grep -c ^Remv` != 0',
        logoutput   => 'on_failure',
        refreshonly => true
    }

    # Dependencies
    Exec['apt-update'] ->
    Exec['apt-upgrade'] ->
    Exec['apt-dist-upgrade'] ->
    Exec['apt-autoremove']
}
