class redis (
    $ensure = $redis::params::ensure
) inherits redis::params {

    package { 'redis':
        ensure => $ensure,
        name   => $redis::params::package
    }

    service { 'redis':
        ensure     => 'running',
        name       => $redis::params::service,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package['redis']
    }

    # There is a redis lens bug in augeas 1.2.x
    apt::ppa { 'ppa:raphink/augeas': }
    apt::key { 'CF6D4DF76A7B62DDCE6C3D99EEDBF1C2AE498453': }

    # Update to latest >= 1.3.0
    package { 'augeas-tools':
        ensure => latest
    }

    augeas { 'redis-set-conf':
        lens    => 'Redis.lns',
        incl    => '/etc/redis/redis.conf',
        changes => [
            'set maxmemory 32mb',
        ],
        require => Package['redis', 'augeas-tools'],
        notify  => Service['redis']
    }

    # http://redis.io/topics/admin
    # set the Linux kernel overcommit memory setting to 1
    #   vm.overcommit_memory = 1
    augeas { 'redis-set-sysctl':
        lens    => 'Sysctl.lns',
        incl    => '/etc/sysctl.conf',
        changes => [
            'set [vm.overcommit_memory] 1',
        ],
        require => Package['redis']
    }

    # disable Linux kernel feature transparent huge pages
    #   if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
    #       echo never > /sys/kernel/mm/transparent_hugepage/enabled
    #   fi
    exec { 'redis-set-transparent-hugepage':
        command => 'echo never > /sys/kernel/mm/transparent_hugepage/enabled',
        onlyif  => 'test -f /sys/kernel/mm/transparent_hugepage/enabled',
        require => Package['redis']
    }
}
