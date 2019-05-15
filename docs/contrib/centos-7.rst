Danube Cloud :: Factory :: Appliances :: CentOS 7
#################################################

Minimal `CentOS 7 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters in zabbix_agentd.conf.
* **org.erigones:zabbix_setup_done**: If set, the configuration of zabbix_agentd.conf will be skipped (set after first deploy).
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.
* **hostname**: Full hostname to be configured by `cloud-init <https://cloudinit.readthedocs.io/>`__ at first boot.

Changelog
---------

20190515
~~~~~~~~

- Version bump to CentOS 7.6 (1810).
- Enable `vmadm console` support - `#130 <https://github.com/erigones/esdc-factory/issues/130>`__
- Added 04-mtu-set.sh to override incorrectly set non-default MTU in KVM - `#430 <https://github.com/erigones/esdc-ce/issues/430>`__

20180207
~~~~~~~~

- Version bump (updated packages).

20170930
~~~~~~~~

- Version bump to CentOS 7.4 (1708).
- Disabled cloud-init network configuration, which could lead to `network being down in VMs after update of cloud-init or CentOS <https://github.com/erigones/esdc-ce/wiki/Known-Issues#network-down-in-vms-after-update-of-cloud-init-or-centos>`__  - `#80 <https://github.com/erigones/esdc-factory/issues/80>`__

20170724
~~~~~~~~

- Version bump.

20170414
~~~~~~~~

- Moved to contrib and changed version format - `#39 <https://github.com/erigones/esdc-factory/issues/39>`__
- Added Zabbix agent package and related metadata - `#39 <https://github.com/erigones/esdc-factory/issues/39>`__

2.5.2
~~~~~

- Added mdata-client (mdata-list, mdata-get, etc.) - commit `a49b73f <https://github.com/erigones/esdc-factory/commit/a49b73f757c7d0f4910179c5934999bb0ce8e4fa>`__
- Increased swap size - `#103 <https://github.com/erigones/esdc-ce/issues/103>`__

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

