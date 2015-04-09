class apt::params {

    # General Settings
    $root           = '/etc/apt'
    $sources_list_d = "${root}/sources.list.d"

    # apt
    $update_frequency = 86400

    # apt::ppa
    $ppa_options    = '-y'

    # apt::upgrade
    $upgrade_dist   = false
    $upgrade_remove = false
}
