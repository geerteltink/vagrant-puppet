# Vagrant Puppet Modules

Collection of composer managed puppet modules for [Vagrant DevBox](https://github.com/xtreamwayz/vagrant-devbox). In stead of using git sub modules composer is being used to update the modules.

Simply create a Vagrant DevBox and run `composer update` to get the latest updates.

## Default settings

Project specific settings can be overridden by copying settings from `<project_root>/vendor/xtreamwayz/hieradata/default.yaml` to `<project_root>/vagrant.yaml`. User specific settings can be set in `~/.devbox/vagrant.yaml`.

- mysql root password: `vagrant`
- mysql default table: `vagrant`
- mysql user: `vagrant`
- mysql password: `vagrant`
- phpmyadmin url: `http://localhost:3333/phpmyadmin`

## Accessing the vagrant box from other devices

By default, nodejs with ngrok is installed. To access the vagrant box from other devices, start [ngrok](https://ngrok.com/) with the `ngrok 80` command inside the box. This generates a url like `http://<hashcode>.ngrok.com/`. Use the generated URL on any device.
