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

$core_packages = ['curl', 'git', 'wget']
package { $core_packages:
    ensure => latest
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
apt::ppa { 'ppa:git-core/ppa': }
apt::key { 'E1DD270288B4E6030699E45FA1715D88E1DF1F24': }

#
# Apache
#

class { 'apache':
    default_mods  => false,
    default_vhost => false,
    mpm_module    => false
}

# MPM worker
class { 'apache::mod::worker': }

# Apache modules authz_host and log_config are core mods
class { 'apache::mod::alias': }
class { 'apache::mod::dir': }
class { 'apache::mod::mime': }
class { 'apache::mod::mime_magic': }
class { 'apache::mod::negotiation': }
class { 'apache::mod::setenvif': }
class { 'apache::mod::rewrite': }
class { 'apache::mod::proxy': }

# Enable mods without classes
apache::mod { 'env': }
apache::mod { 'proxy_fcgi': }

# Setup vhosts from hiera config
create_resources('apache::vhost', hiera_hash('apache::vhosts'))

#
# PHP
#

include php::cli
include php::fpm
include php::composer

# Disable opcache during development
php::ext { 'opcache': ensure => purged }

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
