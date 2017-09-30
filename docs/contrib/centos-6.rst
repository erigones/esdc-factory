Danube Cloud :: Factory :: Appliances :: CentOS 6
#################################################


Minimal `CentOS 6 <https://www.centos.org/>`__ virtual machine with support for initialization through `Cloud-init <https://cloudinit.readthedocs.io/>`__.
The image supports following metadata:

* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``.
* **cloud-init** modules: ssh, set-passwords.

Changelog
---------

20170930
~~~~~~~~

- Version bump.
- Disabled cloud-init network configuration - `#80 <https://github.com/erigones/esdc-factory/issues/80>`__

20170724
~~~~~~~~

- Version bump.

20170414
~~~~~~~~

- Moved to contrib and changed version format - `#39 <https://github.com/erigones/esdc-factory/issues/39>`__

2.5.2
~~~~~

- Added mdata-client (mdata-list, mdata-get, etc.) - commit `a49b73f <https://github.com/erigones/esdc-factory/commit/a49b73f757c7d0f4910179c5934999bb0ce8e4fa>`__

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

