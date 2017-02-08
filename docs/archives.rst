Danube Cloud :: Factory :: Archives
###################################

Tarballs, which become part of the Erigones Danube Cloud USB image.

The tarballs can be created by using the `Ansible build system <../README.rst>`_.

local
=====

Additional software packages managed via pkgsrc.

Can be created using the ``make archive-local`` command or manually on a clean SmartOS installation:

.. code-block:: bash

    cd /
    curl http://pkgsrc.joyent.com/packages/SmartOS/bootstrap/bootstrap-2015Q4-x86_64.tar.gz | gzcat | gtar -C / -xf -
    pkg_admin rebuild
    pkgin -y update
    pkgin -y full-upgrade

    # Install esDC OS dependencies
    pkgin -y install gcc49 gmake autoconf git-base python27 py27-virtualenv

    # Create tarball
    rm -rf /var/db/pkgin/cache/*
    gtar -cvf local-2015Q4-$(date +%Y%m%d).tar /opt/local /var/db/pkgin/cache
    gzip -9 local*.tar


monitoring
==========

Monitoring agent binaries, configurations and monitoring scripts.

Can be created using the ``make archive-monitoring`` command or manually:

.. code-block:: bash

    # Download and unpack Zabbix sources (zabbix-<version>.tar.gz)
    ./configure --prefix=/opt/zabbix --enable-agent
    make
    make install

    # Update /opt/zabbix/etc/zabbix_agentd.conf
    # Add /opt/zabbix/etc/zabbix_agentd.conf.d/esdc-node.conf
    # Add /opt/zabbix/etc/scripts (see usb-archives/monitoring in this repo)
    # Prepare SMF manifests for monitoring services in /opt/custom/smf
    # Create tarball
    gtar -czvf monitoring-2015Q4-$(date +%Y%m%d).tar.gz /opt/zabbix /opt/custom


.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.

