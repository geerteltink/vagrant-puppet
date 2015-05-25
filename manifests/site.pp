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
# Core packages
#

$core_packages = ['curl', 'wget']
package { $core_packages:
    ensure => latest
}

#
# Remove unused packages
#

$remove_packages = ['chef', 'chef-zero', 'ohai']
package { $remove_packages:
    ensure => purged
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
# Update git
#

class { 'git': }

#
# Apache
#

class { 'apache':
    default_mods  => true,
    default_vhost => false,
    mpm_module    => false,
    log_level     => 'error',
    sendfile      => 'Off'
}

# MPM worker
class { 'apache::mod::worker': }

# Apache modules authz_host and log_config are core mods
class { 'apache::mod::rewrite': }
class { 'apache::mod::proxy': }

# Enable mods without classes
apache::mod { 'proxy_fcgi': }

# Setup vhosts from hiera config
create_resources('apache::vhost', hiera_hash('apache::vhosts'))

# Make apache logs accessible
file { '/var/log/apache2':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['apache2']
}

#
# PHP
#

include php::cli
include php::fpm
include php::composer

# Install basic extensions
php::ext { 'curl': }
php::ext { 'gd': }
php::ext { 'intl': }
php::ext { 'mcrypt': }
php::ext { 'mysql': }
php::ext { 'sqlite': }

# Setup php mods from hiera config
create_resources('php::ext', hiera_hash('php::extensions'))

#
# MySQL
#

class { 'mysql::server':
    remove_default_accounts => true
}

# Create database from hiera config
create_resources('mysql::db', hiera_hash('mysql::databases'))

#
# Include extra puppet classes
#

hiera_include('classes')
