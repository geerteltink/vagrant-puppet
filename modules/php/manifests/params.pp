class php::params {

    $ensure       = latest
    $prefix       = 'php5'
    $ext_path     = '/etc/php5/mods-available'

    $cli_mod_path = '/etc/php5/cli/conf.d'
    $cli_ini      = '/etc/php5/cli/php.ini'
    $cli_ini_changes = [
        'set Date/date.timezone UTC'
    ]

    $fpm_mod_path = '/etc/php5/cli/conf.d'
    $fpm_ini      = '/etc/php5/fpm/php.ini'
    $fpm_ini_changes = [
        'set PHP/error_reporting E_ALL',
        'set PHP/display_errors On',
        'set PHP/display_startup_errors On',
        'set PHP/track_errors On',
        'set Date/date.timezone UTC'
    ]
    $fpm_pool     = '/etc/php5/fpm/pool.d/www.conf'
    $fpm_pool_changes = [
        # Restart the deamon once in a while
        'set global/emergency_restart_threshold 5',
        'set global/emergency_restart_interval 1m',
        # Some tuning
        'set www/pm ondemand',
        'set www/pm.max_children 8',
        'set www/pm.process_idle_timeout 10s',
        'set www/pm.max_requests 256',
        # Enable error logging
        "set www/php_admin_value\\[error_log\\] /var/log/${prefix}-fpm.log",
        'set www/php_admin_flag\[log_errors\] on',
        'set www/catch_workers_output yes'
    ]

    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_target  = '/usr/local/bin/composer'
    $composer_max_age = 7
}
