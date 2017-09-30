Danube Cloud :: Factory :: Appliances :: CentOS 7 Desktop
#########################################################

`CentOS 7 <https://www.centos.org/>`__ virtual machine with full GNOME desktop environment. The environment includes Firefox browser, LibreOffice, VNC/RDP client and many other apps.
It also supports initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.

**This image supports remote XDMCP desktop sessions**

To connect to remote session manager in this VM, install base X.org packages on your client and type:
``Xorg -query <vm_IP_address> :1``
Where <vm_IP_address> is the IP address of the deployed CentOS 7 Desktop virtual machine.

* A virtual machine using this image requires at least 1 GB of RAM, preferably more.
* Unprivileged user is not allowed to shut down or reboot the OS using Gnome menu. Root password is requested to do so.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **cloud-init modules**: : growpart, resizefs, ssh, set-passwords


Changelog
---------

20170930
~~~~~~~~

- Renamed image from ``centos7-desktop`` to ``centos-7-desktop``.
- Version bump to CentOS 7.4 (1708).
- Disabled cloud-init network configuration, which could lead to `network being down in VMs after update of cloud-init or CentOS <https://github.com/erigones/esdc-ce/wiki/Known-Issues#network-down-in-vms-after-update-of-cloud-init-or-centos>`__  - `#80 <https://github.com/erigones/esdc-factory/issues/80>`__

20170724
~~~~~~~~

- Version bump.

20170324
~~~~~~~~

- Image created
