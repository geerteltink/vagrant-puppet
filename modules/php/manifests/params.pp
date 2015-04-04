class php::params {

    $ensure       = latest
    $prefix       = 'php5'
    $ext_path     = '/etc/php5/mods-available'

    $cli_mod_path = '/etc/php5/cli/conf.d'
    $cli_ini      = '/etc/php5/cli/php.ini'
    $cli_ini_changes = [
        'set Date/date.timezone Europe/Amsterdam'
    ]

    $fpm_mod_path = '/etc/php5/cli/conf.d'
    $fpm_ini      = '/etc/php5/fpm/php.ini'
    $fpm_ini_changes = [
        'set PHP/error_reporting E_ALL',
        'set PHP/display_errors On',
        'set PHP/display_startup_errors On',
        'set PHP/track_errors On',
        'set Date/date.timezone Europe/Amsterdam'
    ]
    $fpm_pool     = '/etc/php5/fpm/pool.d/www.conf'
    $fpm_pool_changes = [
        'set global/emergency_restart_threshold 5',
        'set global/emergency_restart_interval 1m',
        'set www/pm ondemand',
        'set www/pm.max_children 8',
        'set www/pm.process_idle_timeout 10s',
        'set www/pm.max_requests 256',
        #'set www/pm dynamic',
        #'set www/pm.max_children 8',
        #'set www/pm.start_servers 2',
        #'set www/pm.min_spare_servers 2',
        #'set www/pm.max_spare_servers 4',
        #'set www/pm.max_requests 256'
    ]

    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_target  = '/usr/local/bin/composer'
    $composer_max_age = 7
}
