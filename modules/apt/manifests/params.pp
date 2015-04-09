class apt::params {

    # General Settings
    $root           = '/etc/apt'
    $sources_list_d = "${root}/sources.list.d"

    # apt settings
    $update_frequency = 86400

    # apt::ppa settings
    $ppa_options = '-y'

    $dist_upgrade = false
}
