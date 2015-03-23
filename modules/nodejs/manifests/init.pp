class nodejs (
    $install_npm = true,
    $use_nodesource = true
) {

    if $use_nodesource == true {
        # npm is already included
        $npm_ensure = absent

        apt::source { 'nodesource':
            key               => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
            key_source        => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
            location          => 'https://deb.nodesource.com/node_0.12',
            repos             => 'main',
            required_packages => 'apt-transport-https ca-certificates'
        }
    } elsif $install_npm == true {
        $npm_ensure = present
    } else {
        $npm_ensure = absent
    }

    package { ['nodejs']:
        ensure => latest
    }

    package { ['npm']:
        ensure => $npm_ensure
    }

    # Dependencies
    Package<| title == 'npm' |> ->
    Package['nodejs']

    # Replicates the nodejs-legacy package functionality
    if ($::osfamily == 'Debian') {
        file { '/usr/bin/node':
            ensure  => 'link',
            target  => '/usr/bin/nodejs',
            require => Package['nodejs']
        }
        file { '/usr/share/man/man1/node.1.gz':
            ensure  => 'link',
            target  => '/usr/share/man/man1/nodejs.1.gz',
            require => Package['nodejs']
        }
    }
}
