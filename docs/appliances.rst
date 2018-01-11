Danube Cloud :: Factory :: Appliances
#####################################

Danube Cloud appliances (VM images), which are part of the Danube Cloud first compute node USB image:

    * `base-64-es`_ (OS zone)
    * `esdc-cfgdb`_ (OS zone)
    * `esdc-dns`_ (OS zone)
    * `esdc-img`_ (OS zone)
    * `esdc-mgmt`_ (KVM)
    * `esdc-mon`_ (KVM)

`Additional VM appliances <contrib>`_ are available for download at the public Danube Cloud image repository - https://images.danubecloud.org.


------------------------------------------------------------


base-64-es
==========

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters in zabbix_agentd.conf.

Changelog
---------

3.0.0
~~~~~

- Version bump.

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Version bump.

2.6.4
~~~~~

- Version bump.

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Updated zabbix agent to 3.0.10 - commit `9211f83 <https://github.com/erigones/esdc-factory/commit/9211f8360003d6268ff1643b556b5e1420845ffe>`__

2.6.0
~~~~~

- Updated pkgsrc in /opt/local to 2016Q4 - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__
- Updated zabbix agent to 3.0.9 - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__

2.5.3
~~~~~

- Version bump.

2.5.2
~~~~~

- Switched to zabbix-agent package from pkgsrc.erigones.com - commit `ab681c3 <https://github.com/erigones/esdc-factory/commit/ab681c3929598796d99fdfadfed0e1aede46926c>`__ and commit `d9386cd <https://github.com/erigones/esdc-factory/commit/d9386cddcfa26273d816d7de62d6b5ff13bc078f>`__
- Updated zabbix agent to 3.0.8 - commit `07194fa <https://github.com/erigones/esdc-factory/commit/07194fa5637893b25a0fcc539c4c0c62fef4b836>`__

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

- Version bump.

2.4.0
~~~~~

- Version bump.

2.3.3
~~~~~

- Updated zabbix agent to 3.0.7 - commit `6f338b2 <https://github.com/erigones/esdc-factory/commit/6f338b22c71c3c022063bdd093a60a8afefa2342>`__

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Updated zabbix agent to 3.0.5 - `#7 <https://github.com/erigones/esdc-factory/issues/7>`__

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


esdc-cfgdb
==========

The *esdc-cfgdb* appliance is an OS zone based on the `base-64-es`_ image.
The image supports following metadata (in addition to `base-64-es`_ image metadata):

* **org.erigones:cfgdb_node**: Znode path, which will be created during image deploy (default: ``/esdc``).
* **org.erigones:cfgdb_data**: data for the *org.erigones:cfgdb_node* (default: ``DanubeCloud``).
* **org.erigones:cfgdb_username**: protects the *org.erigones:cfgdb_node* with a username and password (requires *org.erigones:cfgdb_password* to be set, default: ``esdc``).
* **org.erigones:cfgdb_password**: protects the *org.erigones:cfgdb_node* with a username and password (requires *org.erigones:cfgdb_username* to be set).
* **org.erigones:cfgdb_ip**: IP address of cfgdb01.local server that will be configured in port forwarding in local haproxy (optional, default: ``127.0.0.1``)
* **org.erigones:erigonesd_ssl_cert**: SSL certificate to be used by internal Danube Cloud services (optional, no default)
* **org.erigones:erigonesd_ssl_key**: SSL key to be used by internal Danube Cloud services (optional, no default)

Changelog
---------

3.0.0
~~~~~

- Version bump.

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Version bump.

2.6.4
~~~~~

- Version bump.

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Added discovery service for purposes of the compute node installer - `#64 <https://github.com/erigones/esdc-factory/issues/64>`__

2.6.0
~~~~~

- Built from new `base-64-es`_ with 2016Q4 pkgsrc - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__
- Added binaries: zookeepercli, query_cfgdb - `#50 <https://github.com/erigones/esdc-factory/issues/50>`__

2.5.3
~~~~~

- Add support for appending additional SSH authorized_keys into the service VMs - `#43 <https://github.com/erigones/esdc-factory/issues/43>`__

2.5.2
~~~~~

- Version bump.

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

- Version bump.

2.4.0
~~~~~

- Version bump.

2.3.3
~~~~~

- Version bump.

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Version bump.

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


esdc-dns
========

The *esdc-dns* appliance is an OS zone based on the `base-64-es`_ image.
The image supports following metadata (in addition to `base-64-es`_ image metadata):

* **org.erigones:pgsql_host**: ``gpgsql-host`` parameter in pdns.conf.
* **org.erigones:pgsql_port**: ``gpgsql-port`` parameter in pdns.conf.
* **org.erigones:pgsql_user**: ``gpgsql-user`` parameter in pdns.conf.
* **org.erigones:pgsql_password**: ``gpgsql-password`` parameter in pdns.conf.
* **org.erigones:pgsql_dbname**: ``gpgsql-dbname`` parameter in pdns.conf.
* **org.erigones:recursor_forwarders**: sets the ``forward-zones-recurse=.=<metadata-value>`` parameter in recursor.conf.

Changelog
---------

3.0.0
~~~~~

- Version bump.

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Version bump.

2.6.4
~~~~~

- Version bump.

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Version bump.

2.6.0
~~~~~

- Built from new `base-64-es`_ with 2016Q4 pkgsrc - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__
- Fixed problem where the pdns service goes to maintenance state when DB is not reachable - `#48 <https://github.com/erigones/esdc-factory/issues/48>`__
- Added new metadata parameter: `org.erigones:recursor_forwarders` - `#60 <https://github.com/erigones/esdc-factory/issues/60>`__

2.5.3
~~~~~

- Changed default PowerDNS server settings to be preconfigured as a master name server - `#41 <https://github.com/erigones/esdc-factory/issues/41>`__
- Add support for appending additional SSH authorized_keys into the service VMs - `#43 <https://github.com/erigones/esdc-factory/issues/43>`__

2.5.2
~~~~~

- Version bump.

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

- Version bump.

2.4.0
~~~~~

- Version bump.

2.3.3
~~~~~

- Version bump.

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Version bump.

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


esdc-img
========

The *esdc-img* appliance is an OS zone based on the `base-64-es`_ image.

Changelog
---------

3.0.0
~~~~~

- Version bump.

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Version bump.

2.6.4
~~~~~

- Version bump.

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Version bump.

2.6.0
~~~~~

- Built from new `base-64-es`_ with 2016Q4 pkgsrc - `#36 <https://github.com/erigones/esdc-factory/issues/36>`__

2.5.3
~~~~~

- Add support for appending additional SSH authorized_keys into the service VMs - `#43 <https://github.com/erigones/esdc-factory/issues/43>`__

2.5.2
~~~~~

- Version bump.

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

-  Updated versions of the packages in requirements file - commit `503c087 <https://github.com/erigones/esdc-shipment/commit/503c087d353055de48e4c8f056f56f4bc6853974>`__

2.4.0
~~~~~

- Version bump.

2.3.3
~~~~~

- Version bump.

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Version bump.

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


esdc-mgmt
=========

The *esdc-mgmt* appliance is a `CentOS 7 <contrib/centos-7.rst>`_ virtual machine with the Danube Cloud application stack.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters in zabbix_agentd.conf.
* **org.erigones:rabbitmq_password**: esDC RabbitMQ password.
* **org.erigones:redis_password**: esDC Redis password.
* **org.erigones:pgsql_esdc_password**: esDC PostgreSQL password.
* **org.erigones:pgsql_pdns_password**: esDC PostgreSQL password for PowerDNS.
* **org.erigones:pgsql_mgmt_mon_password**: esDC PostgreSQL password for Zabbix agent (optional).
* **org.erigones:zabbix_server**: MON_ZABBIX_SERVER in esDC. If not set, monitoring support will be disabled.
* **org.erigones:zabbix_esdc_username**: MON_ZABBIX_USERNAME in esDC.
* **org.erigones:zabbix_esdc_password**: MON_ZABBIX_PASSWORD in esDC.
* **org.erigones:esdc_admin_email**: change email of admin user.

Changelog
---------

3.0.0
~~~~~

- Fixed /etc/rc.d/rc.local permissions - `#109 <https://github.com/erigones/esdc-factory/issues/109>`__

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Disabled cloud-init network configuration - `#80 <https://github.com/erigones/esdc-factory/issues/80>`__

2.6.4
~~~~~

- Added `org.erigones:pgsql_mgmt_mon_password` metadata parameter - `#72 <https://github.com/erigones/esdc-factory/issues/72>`__
- Added bash-completion package - commit `420d304 <https://github.com/erigones/esdc-factory/commit/420d3042044db9b5557051ad21d66cf6ea66f882>`__
- Modified rabbitmq-server.service to be restarted upon failure - `#71 <https://github.com/erigones/esdc-factory/issues/71>`__

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Version bump.

2.6.0
~~~~~

- Version bump.

2.5.3
~~~~~

- Added bash completion for *es* - commit `ac851d0 <https://github.com/erigones/esdc-factory/commit/ac851d015da0347afa2bf4f4ee6120b83eab12ef>`__
- Add support for appending additional SSH authorized_keys into the service VMs - `#43 <https://github.com/erigones/esdc-factory/issues/43>`__

2.5.2
~~~~~

- Version bump.

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

- Added HTTP connection rate limit for the mgmt web portal - commit `398ce29 <https://github.com/erigones/esdc-factory/commit/398ce29b33e0e4f98794f021342dea44b4eba03b>`

2.4.0
~~~~~

- Removed hardcoded hostname and pre-installed RabbitMQ data dir - `#22 <https://github.com/erigones/esdc-factory/issues/22>`__
- Removed hardcoded hostname in /etc/hosts - commit `54415d0 <https://github.com/erigones/esdc-factory/commit/54415d0a0bdb944c4a159c04304a21fbe395909d>`__
- Disabled monitoring support by default - commit `dd1b671 <https://github.com/erigones/esdc-factory/commit/dd1b6715cbc5494d1d92281613a518486235d120>`__

2.3.3
~~~~~

- Version bump.

2.3.2
~~~~~

- Fixed logrotate in /opt/erigones/var/log - `#20 <https://github.com/erigones/esdc-factory/issues/20>`__

2.3.1
~~~~~

- Added Ansible - `#17 <https://github.com/erigones/esdc-factory/issues/17>`__

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


esdc-mon
========

The *esdc-mon* appliance is a `CentOS 7 <contrib/centos-7.rst>`_ virtual machine with Zabbix server pre-installed.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters in zabbix_agentd.conf.
* **org.erigones:zabbix_esdc_password**: *provisioner* zabbix user password.
* **org.erigones:zabbix_admin_password**: *Admin* zabbix user password.
* **org.erigones:zabbix_admin_email**: create *E-mail* media type with this email for user *Admin*.
* **org.erigones:zabbix_smtp_email**: configure outgoing e-mail address in the *E-mail* media type.

.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.

Changelog
---------

3.0.0
~~~~~

- Fixed monitoring items of erigonesd mgmt worker - `#98 <https://github.com/erigones/esdc-factory/issues/98>`__
- Fixed timezone of the Zabbix frontend - `#106 <https://github.com/erigones/esdc-factory/issues/106>`__
- Fixed /etc/rc.d/rc.local permissions - `#109 <https://github.com/erigones/esdc-factory/issues/109>`__

2.6.7
~~~~~

- Version bump.

2.6.6
~~~~~

- Version bump.

2.6.5
~~~~~

- Added t_svc-db-ha template for monitoring HA status of the PostgreSQL cluster - `#79 <https://github.com/erigones/esdc-factory/issues/79>`__
- Disabled cloud-init network configuration - `#80 <https://github.com/erigones/esdc-factory/issues/80>`__

2.6.4
~~~~~

- Added bash-completion package - commit `420d304 <https://github.com/erigones/esdc-factory/commit/420d3042044db9b5557051ad21d66cf6ea66f882>`__

2.6.3
~~~~~

- Version bump.

2.6.2
~~~~~

- Version bump.

2.6.1
~~~~~

- Added SQL functions and a helper script for managing Zabbix database partitions - `#44 <https://github.com/erigones/esdc-factory/issues/44>`__

2.6.0
~~~~~

- Updated several templates - switched from ZONEID to UUID_SHORT macro - `#49 <https://github.com/erigones/esdc-factory/issues/49>`__

2.5.3
~~~~~

- Decreased severity of *Too many SCSI errors on disk...* alert and increased DISK_ERRORS_THRESHOLD - `#40 <https://github.com/erigones/esdc-factory/issues/40>`__
- Add support for appending additional SSH authorized_keys into the service VMs - `#43 <https://github.com/erigones/esdc-factory/issues/43>`__

2.5.2
~~~~~

- Fixed trigger value to be in line with trigger description in t_erigones-zone - `#28 <https://github.com/erigones/esdc-factory/issues/28>`__
- Updated Ludolph systemd service to start after postgres, pgbouncer and httpd services - commit `0c6ee4a <https://github.com/erigones/esdc-factory/commit/0c6ee4ac00eede5388af215cdb8556b1d4c7f7ca>`__ and commit `a5afec0 <https://github.com/erigones/esdc-factory/commit/a5afec029c5a605d9fc3394ced90b0cb3aec8c7f>`__
- Added externalscripts and alertscripts symlinks in /etc/zabbix - commit `40e99f6 <https://github.com/erigones/esdc-factory/commit/40e99f6cdaf699e87b0edf75c666e35861d1c1cd>`__
- Added sample SMS escalation action - commit `7c4f488 <https://github.com/erigones/esdc-factory/commit/7c4f4886d74750d35a988a74988abafefcb4e8ec>`__
- Added sample Zabbix alert scripts - commit `d4a1c4c <https://github.com/erigones/esdc-factory/commit/d4a1c4c6659c702f22bff92456527e8adcd99b8a>`__
- Added network interface monitoring into t_erigones-zone + small fixes - commit `bc37060 <https://github.com/erigones/esdc-factory/commit/bc37060b5ac77740cb0a3ae034f1cc339acd5b0d>`__
- Disabled cache hit ratio trigger in t_svc-db - commit `3ad5f55 <https://github.com/erigones/esdc-factory/commit/3ad5f5578e7897072fff223e080f0caae415560c>`__
- Fixed exec parameters of default media types - `#29 <https://github.com/erigones/esdc-factory/issues/29>`__
- Fixed FS discovery in t_linux and t_erigonos templates - `#30 <https://github.com/erigones/esdc-factory/issues/30>`__
- Fixed node hard disk discovery and added trigger on SCSI errors into t_solaris_disk - commit `273ad34 <https://github.com/erigones/esdc-factory/commit/273ad34e0c24ab7cb5f2de2f4478534bfa13230e>`__
- Fixed invalid graph description for network monitoring in t_erigonos - `#34 <https://github.com/erigones/esdc-factory/issues/34>`__ - `#112 <https://github.com/erigones/esdc-ce/issues/112>`__

2.5.1
~~~~~

- Version bump.

2.5.0
~~~~~

- Version bump.

2.4.0
~~~~~

- Added used swap metric into compute node monitoring template (t_erigonos) - `#21 <https://github.com/erigones/esdc-factory/issues/21>`__
- Removed hardcoded hostname in /etc/hosts - commit `54415d0 <https://github.com/erigones/esdc-factory/commit/54415d0a0bdb944c4a159c04304a21fbe395909d>`__

2.3.3
~~~~~

- Version bump.

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Disabled trigger "Cache hit ratio of database zabbix is below ??%" - `#8 <https://github.com/erigones/esdc-factory/issues/8>`__
- Disabled trigger "Free swap space is below ??M" on mgmt and mon VMs - `#16 <https://github.com/erigones/esdc-factory/issues/16>`__

2.3.0
~~~~~

- Initial release.


------------------------------------------------------------


centos-6
========

Moved to `contrib/centos-6.rst <contrib/centos-6.rst>`_.

------------------------------------------------------------

centos-7
========

Moved to `contrib/centos-7.rst <contrib/centos-7.rst>`_.

