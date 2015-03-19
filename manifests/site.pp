debug('Starting devbox with hostname: ${::hostname}')

#
# Set defaults
#

include stdlib

File {
    owner => 'root',
    group => 'root',
    mode  => '0644'
}

Exec {
    path => '/usr/bin:/bin:/usr/sbin:/sbin'
}

#
# Update apt
#

# Apt update once a week
exec { 'apt-update':
    command     => 'apt-get update',
    logoutput   => 'on_failure',
    timeout     => 300,
    onlyif      => '/bin/bash -c "exit $(( $(( $(date +%s) - $(stat -c %Y /var/cache/apt/pkgcache.bin) )) <= 604800 ))"'
} -> Package <| |>

# Force apt-get updates
exec { 'apt-update-force':
    command     => 'apt-get update',
    logoutput   => 'on_failure',
    timeout     => 300,
    refreshonly => true
} -> Package <| |>

exec { 'apt-repo apache':
    command => 'add-apt-repository ppa:ondrej/apache2',
    creates => '/etc/apt/sources.list.d/ondrej-apache2-trusty.list',
    notify  => Exec['apt-update-force']
}

exec { 'apt-repo php':
    command => 'add-apt-repository ppa:ondrej/php5-5.6',
    creates => '/etc/apt/sources.list.d/ondrej-php5-5_6-trusty.list',
    notify  => Exec['apt-update-force']
}

exec { 'apt-repo mysql':
    command => 'add-apt-repository ppa:ondrej/mysql-5.6',
    creates => '/etc/apt/sources.list.d/ondrej-mysql-5_6-trusty.list',
    notify  => Exec['apt-update-force']
}

# Sign ondrej sources
exec { 'apt-key ondrej':
    command => 'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C',
    unless  => 'apt-key list | /bin/grep 1024R/E5267A6C',
    notify  => Exec['apt-update-force']
}

#
# Core packages
#

$core_packages = ['curl', 'git']
package { $core_packages:
    ensure => latest
}

#
# Apache
#

# Install apache
class { 'apache':
    default_vhost => false,
    #mpm_module => false,
}
#class { 'apache::mod::prefork': }
#class { 'apache::mod::php': }

# The missing mod_proxy_fcgi class
class apache::mod::proxy_fcgi {
    include ::apache::params
    ::apache::mod { 'proxy_fcgi': }
}

# Install apache modules
apache::mod { 'rewrite': }
apache::mod { 'proxy': }
apache::mod { 'proxy_fcgi': }

# Setup vhost
apache::vhost { $::fqdn:
    default_vhost => true,
    port          => '80',
    docroot       => '/vagrant/public',
    docroot_group => 'www-data',
    docroot_owner => 'www-data',
    directories => [
        {
            path        => '\.php$',
            provider    => 'filesmatch',
            sethandler => 'proxy:unix:/var/run/php5-fpm.sock|fcgi://localhost'
        },
        {
            path            => '/vagrant/public',
            allow_override  => ['All'],
            require         => 'all granted',
            directoryindex  => 'index.php index.html'
        }
    ],
}

#
# PHP
#

# Install php
class { 'php':
    service => 'apache2'
}

# Install php extensions
$phpModules = ['cli', 'fpm', 'curl', 'gd', 'intl', 'mcrypt', 'mysql', 'sqlite']
php::module { $phpModules: }

# Install PECL extensions
$peclModules = ['xdebug']
php::pecl::module { $peclModules: }

# Set PHP config
# TODO: trigger php5-fpm service
class php-config {
    ini_setting { 'php-fpm-error_reporting':
        ensure  => present,
        path    => '/etc/php5/fpm/php.ini',
        section => 'PHP',
        setting => 'error_reporting',
        value   => 'E_ALL'
    }

    ini_setting { 'php-fpm-display_errors':
        ensure  => present,
        path    => '/etc/php5/fpm/php.ini',
        section => 'PHP',
        setting => 'display_errors',
        value   => 'On',
    }

    ini_setting { 'php-fpm-display_startup_errors':
        ensure  => present,
        path    => '/etc/php5/fpm/php.ini',
        section => 'PHP',
        setting => 'display_startup_errors',
        value   => 'On',
    }

    ini_setting { 'php-fpm-track_errors':
        ensure  => present,
        path    => '/etc/php5/fpm/php.ini',
        section => 'PHP',
        setting => 'track_errors',
        value   => 'On',
    }

    ini_setting { 'php-fpm-date_timezone':
        ensure  => present,
        path    => '/etc/php5/fpm/php.ini',
        section => 'Date',
        setting => 'date.timezone',
        value   => 'Europe/Amsterdam',
    }

    ini_setting { 'xdebug-remote_enable':
        ensure  => present,
        path    => '/etc/php5/mods-available/xdebug.ini',
        section => '',
        setting => 'xdebug.remote_enable',
        value   => 'On',
    }

    ini_setting { 'xdebug-remote_connect_back':
        ensure  => present,
        path    => '/etc/php5/mods-available/xdebug.ini',
        section => '',
        setting => 'xdebug.remote_connect_back',
        value   => 'On',
    }

    ini_setting { 'xdebug-idekey':
        ensure  => present,
        path    => '/etc/php5/mods-available/xdebug.ini',
        section => '',
        setting => 'xdebug.idekey',
        value   => 'vagrant',
    }

    ini_setting { 'xdebug-max_nesting_level':
        ensure  => present,
        path    => '/etc/php5/mods-available/xdebug.ini',
        section => '',
        setting => 'xdebug.max_nesting_level',
        value   => 256,
    }
}

class { 'php-config':
    require => Class['php']
}

#
# MySQL
#

$mysql_options = {
    'mysqld' => {
        'collation-server' => 'utf8_unicode_ci',
        'character-set-server' => 'utf8',
        'init-connect' => 'SET NAMES utf8',
        'innodb_file_per_table' => 1
    }
}

class { '::mysql::server':
    root_password           => 'vagrant',
    remove_default_accounts => true,
    override_options        => $mysql_options
}

if file('/vagrant/build/db-schema.sql', '/dev/null') != '' {
    mysql::db { $::hostname:
        user     => $::hostname,
        password => $::hostname,
        host     => 'localhost',
        grant    => ['ALL'],
        sql      => '/vagrant/build/db-schema.sql',
        import_timeout => 900,
    }
} else {
    mysql::db { $::hostname:
        user     => $::hostname,
        password => $::hostname,
        host     => 'localhost',
        grant    => ['ALL']
    }
}

#
# Composer
#

class { 'composer':
    auto_update => true
}

#
# nodejs
#

class { 'nodejs': }

# Install npm packages
$npm_packages = ['bower', 'gulp', 'less', 'uglifycss', 'uglify-js', 'jshint']
package { $npm_packages:
    ensure   => present,
    provider => 'npm',
    require  => Class['nodejs']
}

#
# PhantomJS
#
class { 'phantomjs':
    latest_version => '1.9.8'
}

/*
TODO: class { 'phpmyadmin': }
*/
