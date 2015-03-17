debug('Starting devbox with hostname: ${::hostname}')

# Set defaults for file ownership/permissions
File {
  owner => 'root',
  group => 'root',
  mode  => '0644'
}

# Install core packages
$core_packages = [
    'curl',
    'git'
]

package { $core_packages:
    ensure => latest
}

# Update apt
class { 'apt':
    apt_update_frequency => 'weekly',
    fancy_progress => true
}

# Enable access to the latest apache 2.4.10+
apt::ppa { 'ppa:ondrej/apache2':
    before => Class['apache'],
}

# Get the latest php 5.5.x
apt::ppa { 'ppa:ondrej/php5':
    before  => Class['php'],
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

mysql::db { $::hostname:
    user     => $::hostname,
    password => $::hostname,
    host     => 'localhost',
    grant    => ['ALL']
}

/*
# Composer
class { 'php::composer': }
class { 'php::composer::auto_update':
    max_age => 7
}
*/

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

/*
class { 'phpmyadmin': }

class { 'phantomjs': }
*/
