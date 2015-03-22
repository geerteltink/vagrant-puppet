class php::cli (
    $ensure      = $php::params::ensure,
    $ini_changes = $php::params::cli_ini_changes
) inherits php::params {

    include php

    package { 'php-cli':
        name    => "${php::params::prefix}-cli",
        ensure  => $ensure,
        require => Package['php-common']
    }

    augeas { 'php-cli-ini':
        lens    => 'PHP.lns',
        incl    => "${php::params::cli_ini}",
        changes => $ini_changes,
        require => Package['php-cli']
    }
}
