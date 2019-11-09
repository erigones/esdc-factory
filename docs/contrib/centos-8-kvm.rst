Danube Cloud :: Factory :: Appliances :: CentOS 8 KVM
#####################################################

Minimal `CentOS 8 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__ built primarily for KVM hypervisor.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters in zabbix_agentd.conf.
* **org.erigones:zabbix_setup_done**: If set, the configuration of zabbix_agentd.conf will be skipped (set after first deploy).
* **hostname**: Full hostname to be configured by `cloud-init <https://cloudinit.readthedocs.io/>`__ at first boot.

For **cloud-init** modules usage and configuration, see `cloud-init docs <https://cloudinit.readthedocs.io/en/18.5/topics/modules.html>`__.

Cloud-init example:
===================
This is example for changing root password and configuring remote rsyslog destination.
Add to `customer_metadata` json this value:
```
"cloud-init:user-data": "#cloud-config\nchpasswd:\n expire: false\n list: |   root:MyNewPass123\nrsyslog:\n configs:\n  - \"*.* @@10.100.10.1\n\"",
```

Cloud-init modules run once:
============================
 - bootcmd
 - write-files
 - rsyslog
 - users-groups
 - ssh
 - locale
 - set-passwords
 - timezone
 - runcmd

Cloud-init modules run at every boot:
=====================================
 - growpart
 - resizefs
 - puppet
 - chef
 - salt-minion

Networking
==========
Network config is set to DHCP (configured either by KVM's integrated DHCP server or by external service).

Partition resize
================
Root filesystem is examined and resized if necessary at each boot. Just resize disk and reboot.


Changelog
---------

20191109
~~~~~~~~

- Initial release.

