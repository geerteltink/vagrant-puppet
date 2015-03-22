class php::composer (
    $ensure  = $php::params::ensure,
    $source  = $php::params::composer_source,
    $target  = $php::params::composer_target,
    $max_age = $php::params::composer_max_age
) inherits php::params {

    include php
    include php::cli

    if ! defined(Package['wget']) {
        package { 'wget': ensure => installed }
    }

    exec { 'composer-download':
        command => "wget ${source} -O ${target}",
        creates => $target,
        require => Package['wget', 'php-cli']
    }

    exec { 'composer-update':
        command => "wget ${source} -O ${target}",
        onlyif  => "test `find '${target}' -mtime +${max_age}`",
        require => Package['wget', 'php-cli']
    }

    file { 'composer-permissions':
        path    => $target,
        mode    => '0755',
        owner   => root,
        group   => root,
        require => Exec['composer-download', 'composer-update']
    }

    Exec['composer-download'] -> Exec['composer-update'] -> File['composer-permissions']
}
