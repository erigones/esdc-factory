Danube Cloud :: Factory :: USB Image
####################################

There are two kinds of USB images, which can be installed on physical servers:

    * **compute node** image: this is just the ErigonOS hypervisor + the `esdc-ce <https://github.com/erigones/esdc-ce/>`__ software (erigonesd) running on the node.
    * **head node** image: this is essentially the same as the compute node image, but is also carries 5 VM images, which will be deployed during the installation process into 5 Danube Cloud service virtual machines: mgmt, mon, cfgdb, img, dns.

Both USB images are assembled together from these components:

    - `empty, bootable USB image <https://github.com/erigones/esdc-factory/tree/master/ansible/files/usb/images>`__
    - the `hypervisor platform <platform.rst>`_ - SmartOS raw kernel and boot_archive
    - `VM images and appliances <appliances.rst>`_
    - `archives extracted to /opt <archives.rst>`_
    - ISO images
    - install scripts


Changelog
~~~~~~~~~

2.6.0 (unreleased)
==================

- Updated to new platform version - 20170624T192838Z from upstream/release-20170622 + backported changes from upstream - `#46 <https://github.com/erigones/esdc-factory/issues/46>`__ `#35 <https://github.com/erigones/esdc-factory/issues/35>`__
    - Updated installer (prompt-config), which now supports custom NTP configuration - `#31 <https://github.com/erigones/esdc-factory/issues/31>`__
    - Updated installer to support configuring network tags - `#31 <https://github.com/erigones/esdc-factory/issues/53>`__
    - Added advanced install option
    - Added support for admin_vlan_id into installer
    - Improved cfgdb availability check during installation
    - Added /esdc/settings/dc tree into cfgdb
    - Reboot stderr goes to /dev/null to hide the bootadm update-archive message
    - Added creation of zones/backups/manifests - `esdc-ce#155 <https://github.com/erigones/esdc-ce/issues/155>`__
    - Changed Headnode to Compute node - we want to remove the headnode concept - `esdc-docs#13 <https://github.com/erigones/esdc-docs/issues/13>`__
    - Added netboot and netboot_install_script boot options to support installation from network - `#37 <https://github.com/erigones/esdc-factory/issues/37>`__
- Updated zabbix agent to 3.0.9 [monitoring-2016Q4-20170510] - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__
- Updated pkgsrc to 2016Q4 in local archive [local-2016Q4-20170510] - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__
- Updated SystemRescueCd to version 5.0.2 - commit `83a5edb <https://github.com/erigones/esdc-factory/commit/83a5edb54868220cd6052afd0c04285b8fa2a42e>`__


2.5.3 (released on 2017-05-16)
==============================


2.5.2 (released on 2017-04-11)
==============================

- Fixed "install to HDD" question handling after pressing `no` in the installer's confirmation dialog - commit `d065712 <https://github.com/erigones/esdc-factory/commit/d0657120eef3a5ef472fdf8ad98984d0a4bc598c>`__
- Updated zabbix agent to 3.0.8 [monitoring-2015Q4-20170324] - commit `07194fa <https://github.com/erigones/esdc-factory/commit/07194fa5637893b25a0fcc539c4c0c62fef4b836>`__
- Fixed hard drive discovery on compute node [monitoring-2015Q4-20170324] - commit `273ad34 <https://github.com/erigones/esdc-factory/commit/273ad34e0c24ab7cb5f2de2f4478534bfa13230e>`__
- Fixed various UX issues in installer - `#32 <https://github.com/erigones/esdc-factory/issues/32>`__
- Fixed default value for "hostname" after pressing `no` in the installer's confirmation dialog - commit `4359a88 <https://github.com/erigones/esdc-factory/commit/4359a88874ac57e203c2ba22bac82b541c491556>`__
- Unified indentation of all installer messages - commit `b87ba63 <https://github.com/erigones/esdc-factory/commit/b87ba63a459be1d367ee63d49923d79a9ee90269>`__
- Added default value (*domain name*) for *DNS search domain* in the installer - commit `2a163b2 <https://github.com/erigones/esdc-factory/commit/2a163b285f5940becbd093b1768cafd831096e66>`__

2.5.1 (released on 2017-03-07)
==============================

- Fixed default values for admin_email and DC name after pressing `no` in the installer's confirmation dialog - `#25 <https://github.com/erigones/esdc-factory/issues/25>`__


2.5.0 (released on 2017-03-03)
==============================


2.4.0 (released on 2017-02-22)
==============================

- Importing locally all images on the headnode USB key, so they can be initialized by the esdc-mgmt VM - commit `1a912d1 <https://github.com/erigones/esdc-factory/commit/1a912d1be36a7d6098d7e4d55cf8ed0f7b656b97>`__
- Updated the *local* and *monitoring* archives - `#24 <https://github.com/erigones/esdc-factory/issues/24>`__
- Changed default VCPU count for esDC internal zones to 0 - commit `cd3094b <https://github.com/erigones/esdc-factory/commit/cd3094b009107a7dc1e88931c47bab0c31f2166e>`__
- Fixed error message when no disks are available during installation - commit `fa9eda2 <https://github.com/erigones/esdc-factory/commit/fa9eda26e63b6630cb645287af084579d64ca8bd>`__
- Fixed internal SSH connection when network is not available - commit `faf8a4b <https://github.com/erigones/esdc-factory/commit/faf8a4bfbc4b518e34a4dd0f836a28f38303ea86>`__
- Fixed situation when running mount-usb from HDD-installed machine - commit `f68eb5b <https://github.com/erigones/esdc-factory/commit/f68eb5bfdbf8a9fee817ae272b024270c06d43d5>`__


2.3.3 (released on 2017-02-04)
==============================

- Fixed esdc_install_password handling (added missing quotes) in installer - `#23 <https://github.com/erigones/esdc-factory/issues/23>`__

2.3.2 (released on 2016-12-17)
==============================


2.3.1 (released on 2016-12-15)
==============================

- Fixed zookeepercli command error log in _zk() in computenode.sh - `#4 <https://github.com/erigones/esdc-factory/issues/4>`__
- Updated zabbix agent to 3.0.5 [monitoring-2015Q4-20161127] - `#7 <https://github.com/erigones/esdc-factory/issues/7>`__
- Updated packages in local archive [local-2015Q4-20161127] - `#9 <https://github.com/erigones/esdc-factory/issues/9>`__
- Fixed zabbix_agentd.conf configuration during compute node installation - `#10 <https://github.com/erigones/esdc-factory/issues/10>`__
- Removed old code from prompt-config.sh, headnode.sh, computenode.sh - `#2 <https://github.com/erigones/esdc-factory/issues/12>`__
- Fixed alignment of some messages - `#3 <https://github.com/erigones/esdc-factory/issues/3>`__
- Added functionality for adding the mgmt SSH key to all service VMs during headnode installation - `#18 <https://github.com/erigones/esdc-factory/issues/18>`__

2.3.0 (released on 2016-11-17)
==============================

- Going open source. Yeah!

