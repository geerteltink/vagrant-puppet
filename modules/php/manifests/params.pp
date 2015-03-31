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

    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_target  = '/usr/local/bin/composer'
    $composer_max_age = 7
}
