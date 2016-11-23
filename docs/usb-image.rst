Danube Cloud :: Factory :: USB Image
####################################

There are two kinds of USB images, which can be installed on physical servers:

    * **compute node** image: this is just the ErigonOS hypervisor + the `esdc-ce <https://github.com/erigones/esdc-ce/>`__ software (erigonesd) running on the node.
    * **head node** image: this is essentially the same as the compute node image, but is also carries 5 VM images, which will be deployed during the installation process into 5 Danube Cloud service virtual machines: mgmt, mon, cfgdb, img, dns.

Both USB images are assembled together from these components:

    - `empty, bootable USB image <https://github.com/erigones/esdc-factory/tree/master/ansible/files/usb/images>`__
    - the `hypervisor platform <platform.rst>`_ - SmartOS raw kernel and boot_archive
    - `VM images and appliances <appliances.rst>`_
    - ISO images
    - install scripts


Changelog
~~~~~~~~~

2.3.0 (released on 2016-11-17)
========================================

Features
--------

- Going open source. Yeah!

Bugs
----

