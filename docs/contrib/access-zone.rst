Danube Cloud :: Factory :: Appliances :: Access Zone
####################################################

`Dedicated router image for `Danube Cloud <https://danubecloud.org>`__.

This is a SunOS zone image with enabled routing, firewall and NAT. It supports initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
In order to use it, you should create a VM in a following way:
* The net0 network interface (the first one) has to be a WAN interface (all outgoing traffic from this interface will be masqueraded)
* All other network interfaces need to have the *Allow IP Spoofing* option enabled (otherwise all routed packets will be dropped)

.. note:: A virtual machine using this image requires at least 1 GB of RAM.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.


Changelog
---------

20170714
~~~~~~~~

- Image created

