define apt::key (
    $fingerprint = $title
) {

    include apt::params
    include apt::update

    validate_re($fingerprint, ['\A(0x)?[0-9a-fA-F]{8}\Z', '\A(0x)?[0-9a-fA-F]{16}\Z', '\A(0x)?[0-9a-fA-F]{40}\Z'])

    # Get the key (last 8 characters)
    $key = regsubst($fingerprint, '^(.*)(.{8})$', '\2')

    exec { "apt-key-$fingerprint":
        command     => "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $fingerprint",
        unless      => "apt-key list | /bin/grep 1024R/$key",
        logoutput   => 'on_failure',
        notify      => Exec['apt-update']
    }
}
