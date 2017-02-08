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

