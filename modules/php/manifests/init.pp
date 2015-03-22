class php (
    $ensure = $php::params::ensure
) inherits php::params {

    package { 'php-common':
        name   => "${php::params::prefix}-common",
        ensure => $ensure
    }
}
