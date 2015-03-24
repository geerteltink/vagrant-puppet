#
# Development references
#
# https://docs.puppetlabs.com/references/latest/type.html
# https://docs.puppetlabs.com/references/latest/function.html
# http://manpages.ubuntu.com/manpages/hardy/man1/test.1posix.html
#

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

include apt
include apt::upgrade

apt::ppa { 'ppa:ondrej/apache2': }
apt::ppa { 'ppa:ondrej/php5-5.6': }
apt::ppa { 'ppa:ondrej/mysql-5.6': }
apt::key { '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C': }

#
# Core packages
#

$core_packages = ['curl', 'git', 'wget']
package { $core_packages:
    ensure => latest
}

#
# Apache
#

class { 'apache':
    default_vhost => false,
}

# The missing mod_proxy_fcgi class
class apache::mod::proxy_fcgi {
    include ::apache::params
    ::apache::mod { 'proxy_fcgi': }
}

# Install apache modules
apache::mod { 'rewrite': }
apache::mod { 'proxy': }
apache::mod { 'proxy_fcgi': }

# Setup default vhost for the vagrant dir
apache::vhost { $::fqdn:
    default_vhost => true,
    port          => '80',
    docroot       => '/vagrant/public',
    docroot_group => 'www-data',
    docroot_owner => 'www-data',
    serveraliases => ['*.ngrok.com'],
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
    ]
}

#
# PHP
#

include php::cli
include php::fpm
include php::composer

php::ext { 'curl': }
php::ext { 'gd': }
php::ext { 'intl': }
php::ext { 'mcrypt': }
php::ext { 'mysql': }
php::ext { 'sqlite': }
php::ext { 'xdebug':
    ini_changes => [
        'set .anon/xdebug.remote_enable On',
        'set .anon/xdebug.remote_connect_back On',
        'set .anon/xdebug.idekey vagrant',
        'set .anon/xdebug.max_nesting_level 256',
    ]
}

#
# MySQL
#

$mysql_options = {
    'mysqld' => {
        'collation-server' => 'utf8_unicode_ci',
        'character-set-server' => 'utf8',
        'init-connect' => 'SET NAMES utf8',
        'innodb_file_per_table' => 1,
        'bind-address' => '0.0.0.0'
    }
}

class { '::mysql::server':
    root_password           => 'vagrant',
    remove_default_accounts => true,
    override_options        => $mysql_options
}

if file('/vagrant/build/db-schema.sql', '/dev/null') != '' {
    $sql = '/vagrant/build/db-schema.sql'
} else {
    $sql = undef
}
mysql::db { $::hostname:
    user     => $::hostname,
    password => $::hostname,
    host     => '%',
    grant    => ['ALL'],
    sql      => $sql,
    import_timeout => 900,
    enforce_sql => false
}

#
# Extra packages
#

include phpmyadmin

include phantomjs

include nodejs

nodejs::npm { 'bower': }
nodejs::npm { 'gulp': }
nodejs::npm { 'jshint': }
nodejs::npm { 'less': }
nodejs::npm { 'uglify-js': }
nodejs::npm { 'uglifycss': }

# Running ``ngrok 80`` inside the vagrant box gives an URL which can be used to
# access the box from the outside world
nodejs::npm { 'ngrok': }
