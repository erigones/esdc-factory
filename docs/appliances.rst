Danube Cloud :: Factory :: Appliances
#####################################

Danube Cloud appliances (VM images), which are part of the Danube Cloud head node image:

    * `base-64-es`_ (OS zone)
    * `esdc-cfgdb`_ (OS zone)
    * `esdc-dns`_ (OS zone)
    * `esdc-img`_ (OS zone)
    * `esdc-mgmt`_ (KVM)
    * `esdc-mon`_ (KVM)

Additional VM appliances are available for download at the public Danube Cloud image repository - https://images.danubecloud.org:

    * `centos-6`_ (KVM)
    * `centos-7`_ (KVM)


------------------------------------------------------------


base-64-es
==========

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.

Changelog
---------

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

Changelog
---------

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

Changelog
---------

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

The *esdc-mgmt* appliance is a `centos-7`_ virtual machine with the Danube Cloud application stack.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **org.erigones:rabbitmq_password**: esDC RabbitMQ password.
* **org.erigones:redis_password**: esDC Redis password.
* **org.erigones:pgsql_esdc_password**: esDc PostgreSQL password.
* **org.erigones:pgsql_pdns_password**: esDC PostgreSQL password for PowerDNS.
* **org.erigones:zabbix_server**: MON_ZABBIX_SERVER in esDC. If not set, monitoring support will be disabled.
* **org.erigones:zabbix_esdc_username**: MON_ZABBIX_USERNAME in esDC.
* **org.erigones:zabbix_esdc_password**: MON_ZABBIX_PASSWORD in esDC.
* **org.erigones:esdc_admin_email**: change email of admin user.

Changelog
---------

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

The *esdc-mon* appliance is a `centos-7`_ virtual machine with Zabbix server pre-installed.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **org.erigones:zabbix_esdc_password**: *provisioner* zabbix user password.
* **org.erigones:zabbix_admin_password**: *Admin* zabbix user password.
* **org.erigones:zabbix_admin_email**: create *E-mail* media type with this email for user *Admin*.
* **org.erigones:zabbix_smtp_email**: configure outgoing e-mail address in the *E-mail* media type.

.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.

Changelog
---------

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

Minimal `CentOS 6 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: ssh, set-passwords.

Changelog
---------

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


centos-7
========

Minimal `CentOS 7 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.

Changelog
---------

2.5.0
~~~~~

- Version bump.

2.4.0
~~~~~

- Version bump.

2.3.3
~~~~~

- Removed chrony (using ntpd instead) - commit `17880ed <https://github.com/erigones/esdc-factory/commit/17880ed7459ae455151eabb65094d5e91327d8f2>`__

2.3.2
~~~~~

- Version bump.

2.3.1
~~~~~

- Version bump.

2.3.0
~~~~~

- Initial release.

