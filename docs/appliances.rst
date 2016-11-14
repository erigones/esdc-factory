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


base-64-es
==========

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.


esdc-cfgdb
==========

The *esdc-cfgdb* appliance is an OS zone based on the `base-64-es`_ image.
The image supports following metadata (in addition to `base-64-es`_ image metadata):

* **org.erigones:cfgdb_node**: Znode path, which will be created during image deploy (default: ``/esdc``).
* **org.erigones:cfgdb_data**: data for the *org.erigones:cfgdb_node* (default: ``DanubeCloud``).
* **org.erigones:cfgdb_username**: protects the *org.erigones:cfgdb_node* with a username and password (requires *org.erigones:cfgdb_password* to be set, default: ``esdc``).
* **org.erigones:cfgdb_password**: protects the *org.erigones:cfgdb_node* with a username and password (requires *org.erigones:cfgdb_username* to be set).


esdc-dns
========

The *esdc-dns* appliance is an OS zone based on the `base-64-es`_ image.
The image supports following metadata (in addition to `base-64-es`_ image metadata):

* **org.erigones:pgsql_host**: ``gpgsql-host`` parameter in pdns.conf.
* **org.erigones:pgsql_port**: ``gpgsql-port`` parameter in pdns.conf.
* **org.erigones:pgsql_user**: ``gpgsql-user`` parameter in pdns.conf.
* **org.erigones:pgsql_password**: ``gpgsql-password`` parameter in pdns.conf.
* **org.erigones:pgsql_dbname**: ``gpgsql-dbname`` parameter in pdns.conf.


esdc-img
========

The *esdc-img* appliance is an OS zone based on the `base-64-es`_ image.


esdc-mgmt
=========

The *esdc-mgmt* appliance is a CentOS 7 virtual machine with the Danube Cloud application stack.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **org.erigones:rabbitmq_password**: esDC RabbitMQ password.
* **org.erigones:redis_password**: esDC Redis password.
* **org.erigones:pgsql_esdc_password**: esDc PostgreSQL password.
* **org.erigones:pgsql_pdns_password**: esDC PostgreSQL password for PowerDNS.
* **org.erigones:zabbix_server**: MON_ZABBIX_SERVER in esDC. If not set, value of *org.erigones:zabbix_ip* will be used.
* **org.erigones:zabbix_esdc_username**: MON_ZABBIX_USERNAME in esDC.
* **org.erigones:zabbix_esdc_password**: MON_ZABBIX_PASSWORD in esDC.
* **org.erigones:esdc_admin_email**: change email of admin user.


esdc-mon
========

The *esdc-mon* appliance is a CentOS 7 virtual machine with Zabbix server pre-installed.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **org.erigones:zabbix_esdc_password**: *provisioner* zabbix user password.
* **org.erigones:zabbix_admin_password**: *Admin* zabbix user password.
* **org.erigones:zabbix_admin_email**: create *E-mail* media type with this email for user *Admin*.
* **org.erigones:zabbix_smtp_email**: configure outgoing e-mail address in the *E-mail* media type.

.. note:: Zabbix is a registered trademark of `Zabbix LLC <http://www.zabbix.com>`_.


centos-6
========

Minimal `CentOS 6 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: ssh, set-passwords.


centos-7
========

Minimal `CentOS 7 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.

