class php::fpm (
    $ensure       = $php::params::ensure,
    $ini_changes  = $php::params::fpm_ini_changes,
    $pool_changes = $php::params::fpm_pool_changes
) inherits php::params {

    include php

    package { 'php-fpm':
        name    => "${php::params::prefix}-fpm",
        ensure  => $ensure,
        require => Package['php-common']
    }

    service { 'php-fpm-service':
        name    => "${php::params::prefix}-fpm",
        ensure  => running,
        require => Package['php-fpm']
    }

    augeas { 'php-fpm-ini':
        lens    => 'PHP.lns',
        incl    => "${php::params::fpm_ini}",
        changes => $ini_changes,
        require => Package['php-fpm'],
        notify  => Service['php-fpm-service']
    }

    augeas { 'php-fpm-pool':
        lens    => 'PHP.lns',
        incl    => "${php::params::fpm_pool}",
        changes => $pool_changes,
        require => Package['php-fpm'],
        notify  => Service['php-fpm-service']
    }

    file { 'php-fpm-log':
        path    => "/var/log/${php::params::prefix}-fpm.log",
        ensure  => 'file',
        mode    => '0644',
        require => Package['php-fpm'],
        notify  => Service['php-fpm-service']
    }
}
