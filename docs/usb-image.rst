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

2.4.0 (unreleased)
==================

- Importing locally all images on the headnode USB key, so they can be initialized by the esdc-mgmt VM - commit `1a912d1 <https://github.com/erigones/esdc-factory/commit/1a912d1be36a7d6098d7e4d55cf8ed0f7b656b97>`__
- Updated the *local* and *monitoring* archives - `#24 <https://github.com/erigones/esdc-factory/issues/24>`__
- Changed default VCPU count for esDC internal zones to 0 - commit `cd3094b <https://github.com/erigones/esdc-factory/commit/cd3094b009107a7dc1e88931c47bab0c31f2166e>`__
- Fixed handling of installation input by adding quotes around config variables - commit `c0fe89b <https://github.com/erigones/esdc-factory/commit/c0fe89b883c483bd3ecd7e394cd76bea1bf4c04f>`__
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

