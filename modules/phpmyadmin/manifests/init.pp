class phpmyadmin (
    $source  = $phpmyadmin::params::source,
    $branch  = $phpmyadmin::params::branch,
    $user    = $phpmyadmin::params::user,
    $version = '4_3_13'
) inherits phpmyadmin::params {

    $file_name = "RELEASE_${version}"
    $target = "/usr/share"
    $download_url = "https://github.com/phpmyadmin/phpmyadmin/archive/${file_name}.tar.gz"

    if ! defined(Package['wget']) {
        package { 'wget': ensure => installed }
    }

    file { '/var/phpmyadmin':
        ensure => directory
    }

    exec { 'phpmyadmin-retrieve':
        command => "wget $download_url -O /var/phpmyadmin/${file_name}.tar.gz",
        creates => "/var/phpmyadmin/${file_name}.tar.gz",
        require => Package['wget']
    }

    exec { 'phpmyadmin-unpack':
        command => "tar -xvzf /var/phpmyadmin/${file_name}.tar.gz -C ${target}",
        creates => "${target}/${file_name}"
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
    File['/var/phpmyadmin'] ->
    Exec['phpmyadmin-retrieve'] ->
    Exec['phpmyadmin-unpack'] ->
    File['phpmyadmin-conf'] ->
    File['phpmyadmin-enable']
}
