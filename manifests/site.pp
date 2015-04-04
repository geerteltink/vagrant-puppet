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
    default_mods  => false,
    default_vhost => false,
    log_level     => 'error',
    mpm_module    => false
}

# worker MPM
# StartServers: initial number of server processes to start
# MaxClients: maximum number of simultaneous client connections
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestsPerChild: maximum number of requests a server process serves
class { 'apache::mod::worker':
    startservers        => '1',
    serverlimit         => '4',
    maxclients          => '16',
    minsparethreads     => '8',
    maxsparethreads     => '16',
    threadsperchild     => '32',
    maxrequestsperchild => '256',
    threadlimit         => '32'
}

# The missing mod_proxy_fcgi class
class apache::mod::proxy_fcgi {
    include ::apache::params
    ::apache::mod { 'proxy_fcgi': }
}

# Apache modules authz_host and log_config are core mods
class { 'apache::mod::alias': }
class { 'apache::mod::dir': }
class { 'apache::mod::mime': }
class { 'apache::mod::mime_magic': }
class { 'apache::mod::negotiation': }
class { 'apache::mod::setenvif': }
class { 'apache::mod::rewrite': }
class { 'apache::mod::proxy': }
class { 'apache::mod::proxy_fcgi': }

# Setup default vhost for the vagrant dir
apache::vhost { $::fqdn:
    default_vhost => true,
    port          => '80',
    docroot       => '/vagrant/public',
    docroot_group => 'www-data',
    docroot_owner => 'www-data',
    serveraliases => ['*.ngrok.com'],
    access_log    => false,
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

# Disable opcache during development
php::ext { 'opcache': ensure => purged }

#
# MySQL
#

$mysql_options = {
    'mysqld' => {
        'collation-server' => 'utf8_unicode_ci',
        'character-set-server' => 'utf8',
        'init-connect' => 'SET NAMES utf8',
        'bind-address' => '0.0.0.0',
        'performance_schema' => 0,
        'key_buffer_size' => '16M',
        # Safefy
        'max_allowed_packet' => '16M',
        'sql_mode' => 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_AUTO_VALUE_ON_ZERO,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ONLY_FULL_GROUP_BY',
        # Caches and Limits
        'max_connections' => '128',
        'table_open_cache' => '2048',
        # InnoDB
        'innodb_file_per_table' => '1',
        'innodb_flush_log_at_trx_commit' => '1'
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
