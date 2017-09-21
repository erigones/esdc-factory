Danube Cloud :: Factory :: Appliances :: GitLab CE
##################################################

`GitLab <https://gitlab.com>`__ Community Edition (Omnibus) image for `Danube Cloud <https://danubecloud.org>`__.

The GitLab Omnibus package is installed on minimal `CentOS 7 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.

.. note:: A virtual machine using this image requires at least 1 GB of RAM.

The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: growpart, resizefs, ssh, set-passwords.
* **org.erigones:zabbix_ip**: ``Server`` and ``ServerActive`` parameters zabbix_agentd.conf.
* **gitlab:external_url**: `external URL for GitLab <https://docs.gitlab.com/omnibus/settings/configuration.html#configuring-the-external-url-for-gitlab>`__. If not specified for the first server boot, a ``https://$(hostname)`` value will be used. Additionally, `HTTPS support <https://docs.gitlab.com/omnibus/settings/nginx.html#enable-https>`__ is automatically enabled depending on the URL scheme. A self-signed SSL certificate will be generated during the first boot.


Changelog
---------

20170922
~~~~~~~~

- CentOS 7.4 (1708)
- GitLab CE 9.5.5
- Fixed critical NIC naming problem, which could lead to `network being down in VMs after update of cloud-init or CentOS <https://github.com/erigones/esdc-ce/wiki/Known-Issues#network-down-in-vms-after-update-of-cloud-init-or-centos>`__.

20170724
~~~~~~~~

- GitLab CE 9.4.0

20170414
~~~~~~~~

- GitLab CE 9.0.5


20170222
~~~~~~~~

- GitLab CE 8.16.6
