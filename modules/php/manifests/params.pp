class php::params {

    $ensure     = latest
    $prefix     = 'php5'

    $cli_ini    = '/etc/php5/cli/php.ini'
    $cli_ini_changes = [
        'set Date/date.timezone Europe/Amsterdam'
    ]

    $fpm_ini    = '/etc/php5/fpm/php.ini'
    $fpm_ini_changes = [
        'set PHP/error_reporting E_ALL',
        'set PHP/display_errors On',
        'set PHP/display_startup_errors On',
        'set PHP/track_errors On',
        'set Date/date.timezone Europe/Amsterdam'
    ]

    $ext_path   = '/etc/php5/mods-available'
}
