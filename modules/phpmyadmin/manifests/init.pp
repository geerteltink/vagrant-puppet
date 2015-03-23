class phpmyadmin (
    $source = 'https://github.com/phpmyadmin/phpmyadmin.git',
    $path   = '/srv/phpmyadmin',
    $user   = 'www-data',
    $branch = 'STABLE'
) {

    if ! defined(Package['git']) {
        package { 'git': ensure => installed }
    }

    file { $path:
        ensure => directory,
        owner  => $user
    }

    # Download a single phpmyadmin branch only to speed things up
    exec { 'phpmyadmin-clone':
        command => "git clone $source --depth 1 --branch $branch --single-branch .",
        cwd     => $path,
        creates => "$path/.git",
        require => Package['git', 'apache2', 'php-fpm']
    }

    # Update phpmyadmin
    exec { 'phpmyadmin-update':
        command => "git pull",
        cwd     => $path
    }

    file { 'phpmyadmin-conf':
        path    => '/etc/apache2/sites-available/20-phpmyadmin.conf',
        content => template('phpmyadmin/_header.erb', 'phpmyadmin/phpmyadmin.conf.erb'),
        mode    => '0644',
        notify  => Service['apache2']
    }

    file { 'phpmyadmin-enable':
        ensure => 'link',
        path   => '/etc/apache2/sites-enabled/20-phpmyadmin.conf',
        target => '/etc/apache2/sites-available/20-phpmyadmin.conf',
        notify  => Service['apache2']
    }

    # Dependencies
    File[$path] ->
    Exec['phpmyadmin-clone'] ->
    Exec['phpmyadmin-update'] ->
    File['phpmyadmin-conf'] ->
    File['phpmyadmin-enable']
}
