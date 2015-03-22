define php::ext (
    $extension_name = $title,
    $ensure         = $php::params::ensure,
    $ini_changes    = undef
) {

    include php
    include php::params

    if defined(Service['php-fpm-service']) {
        $notify = Service['php-fpm-service']
    } else {
        $notify = undef
    }

    package { "${php::params::prefix}-${extension_name}":
        ensure  => $ensure,
        require => Package['php-common'],
        notify  => $notify
    }

    if $ini_changes {
        augeas { "${php::params::prefix}-${extension_name}-ini":
            lens => 'PHP.lns',
            incl => "${php::params::ext_path}/${extension_name}.ini",
            changes => $ini_changes,
            require => Package["${php::params::prefix}-${extension_name}"],
            notify => $notify
        }
    }

    Package <| title=='php-cli' |> -> Package <| title=='php-fpm' |> -> Package["${php::params::prefix}-$extension_name"]
}
