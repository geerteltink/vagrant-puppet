# == Class: PhantomJS
#
# Installs packages for PhantomJS as a deamon.
#
class phantomjs ($version = '1.9.8') {

    $file_name = "phantomjs-${version}-linux-x86_64"
    $download_url = "https://bitbucket.org/ariya/phantomjs/downloads/${file_name}.tar.bz2"

    package { ['libfontconfig1']:
        ensure => installed
    }

    if $::kernel == 'Linux' {
        if ! defined(Package['wget']) {
            package { 'wget': ensure => installed }
        }
    }

    file { '/var/phantomjs':
        ensure => directory,
        before => Exec['phantomjs-retrieve']
    }

    exec { 'phantomjs-retrieve':
        command => "wget $download_url -O /var/phantomjs/${file_name}.tar.bz2",
        path    => ['/bin', '/usr/bin'],
        creates => "/var/phantomjs/${file_name}.tar.bz2",
        require => Package['libfontconfig1', 'wget']
    }

    exec { 'phantomjs-unpack':
        command => "tar xjf /var/phantomjs/${file_name}.tar.bz2 -C /usr/share",
        path    => ['/bin', '/usr/bin'],
        creates => "/usr/share/${file_name}",
        require => Exec['phantomjs-retrieve']
    }

    file { '/usr/local/share/phantomjs':
        ensure => 'link',
        force => true,
        target => "/usr/share/${file_name}/bin/phantomjs",
        require => Exec['phantomjs-unpack']
    }

    file { '/usr/local/bin/phantomjs':
        ensure => 'link',
        force => true,
        target => "/usr/share/${file_name}/bin/phantomjs",
        require => Exec['phantomjs-unpack']
    }

    file { '/usr/bin/phantomjs':
        ensure => 'link',
        force => true,
        target => "/usr/share/${file_name}/bin/phantomjs",
        require => Exec['phantomjs-unpack']
    }

    # Create deamon
    file { '/etc/init.d/phantomjs':
        content => template('phantomjs/phantomjs-deamon.erb'),
        owner => 'root',
        group => 'root',
        mode  => '0755',
        require => [Exec['phantomjs-unpack'], File['/usr/bin/phantomjs']]
    }

    # Start deamon
    service { 'phantomjs':
        enable => true,
        ensure  => running,
        require => [Exec['phantomjs-unpack'], File['/etc/init.d/phantomjs']]
    }
}
