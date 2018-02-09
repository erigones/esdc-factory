Danube Cloud :: Factory :: Appliances :: Access Zone
####################################################

`Dedicated router image for `Danube Cloud <https://danubecloud.org>`__.

This is a lightweight SunOS zone image with enabled packet forwarding, firewall and NAT. It supports initialization through `Zoneinit <https://github.com/joyent/zoneinit>`__.
The *network-access-zone* appliance is based on the `base-64-es <https://github.com/erigones/esdc-factory/blob/master/docs/appliances.rst#base-64-es>`__ image.

In order to use it, create a SunOS zone in a following way:
* The net0 network interface (the first one) has to be a WAN interface (all outgoing traffic from this interface will be masqueraded)
* All other network interfaces need to have the *Allow IP Spoofing* option enabled (otherwise all routed packets will be dropped)

Firewall configuration can be altered here:
* Filter: ``/etc/ipf/ipf.conf``
* NAT and port mapper: ``/etc/ipf/ipnat.conf``
* Apply: svcadm refresh ipfilter

.. note:: A virtual machine using this image requires at least 256 MB of RAM.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters for zabbix_agentd.conf.


Changelog
---------

20180209
~~~~~~~~

- Based on 2017Q4 base-64-es 3.0.0 image.


20170808
~~~~~~~~

- Image created

