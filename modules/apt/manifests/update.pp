class apt::update {

    # Run apt-get update when asked for
    exec { 'apt-update':
        command     => 'apt-get update',
        logoutput   => 'on_failure',
        timeout     => 300,
        refreshonly => true
    }

    Exec['apt-update'] -> Package <| |>
}
