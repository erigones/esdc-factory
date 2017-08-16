Danube Cloud :: Factory :: Appliances :: LeoFS
##############################################

`LeoFS <http://leo-project.net/leofs/>`__ appliance for `Danube Cloud <https://danubecloud.org>`__ and `SmartOS <https://smartos.org>`__.

This is a SunOS zone image with pre-installed leofs-storage, leofs-gateway and leofs-manager packages. LeoFS is an Enterprise Open Source Storage, and it is a highly available, distributed, eventually consistent object/blob store

The *storage-leofs* appliance is based on the `base-64-es<https://github.com/erigones/esdc-factory/blob/master/docs/appliances.rst#base-64-es>`__ image.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters for zabbix_agentd.conf.

Changelog
---------

20170816
~~~~~~~~

- Image created

