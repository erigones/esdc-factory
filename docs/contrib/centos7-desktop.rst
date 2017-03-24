Danube Cloud :: Factory :: Appliances :: Centos 7 Desktop
#########################################################

`CentOS 7 <https://www.centos.org/>`__ virtual machine with full GNOME desktop environment. The environment includes Firefox browser, Libre Office, VNC/RDP client and many other apps.
It also supports for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.

**This image supports remote XDMCP desktop sessions**
To connect to remote session manager in this VM, install a base xorg packages on your client and type:
``Xorg -query <vm_IP_address> :1``
Where <vm_IP_address> is IP of the deployed Centos 7 Desktop virtual machine.

.. note:: A virtual machine using this image requires at least 1 GB of RAM, preferably more.

.. note:: Unprivileged user is not allowed to shut down or reboot the OS using Gnome menu. Root password is requested to do so.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.


Changelog
---------

20170324
~~~~~~~~

- Image created
