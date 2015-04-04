Vagrant Puppet Modules
======================

This is being used by [Vagrant DevBox](https://github.com/twentyfirsthall/vagrant-devbox). These modules are managed and updated by composer. Simply create a Vagrant DevBox and run ``composer update`` to get the latest updates.

Default settings
----------------

Default settings can be overridden by creating `<project_root>/build/vagrant.yaml` and copying settings from `<project_root>/vendor/twentyfirsthall/hieradata/default.yaml`.

- mysql root password: `vagrant`
- mysql table: `vagrant`
- mysql user: `vagrant`
- mysql password: `vagrant`
- phpmyadmin url: `http://localhost:3333/phpmyadmin`

Accessing the vagrant box from other devices
--------------------------------------------

By default, nodejs with ngrok is installed. To access the vagrant box from other devices, start [ngrok](https://ngrok.com/) with `ngrok 80` inside the box. This generates a url like `http://<hashcode>.ngrok.com/`. Use the generated URL on any device.
