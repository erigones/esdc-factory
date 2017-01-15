Danube Cloud :: Factory
#######################

This repository is used for building various components of Erigones Danube Cloud, as well as the final Danube Cloud USB key image.


Output
======

All build results are stored in following folders in ``build_base_dir``:

* **appliances**: `Danube Cloud appliances <docs/appliances.rst>`_ (VM images), which then become part of the Danube Cloud USB image

    * base-64-es
    * esdc-mon
    * esdc-mgmt
    * esdc-cfgdb
    * esdc-dns
    * esdc-img

* **isos**: ISO images, which are downloaded from external sources and become part of the Danube Cloud USB image.

* **archives**: `Tarballs <docs/archives.rst>`_, which become part of the Danube Cloud USB image (/opt)

    * local
    * monitoring
    * esdc-node

* **platform**: Tarballs, which contain the `hypervisor platform <docs/platform.rst>`_ - SmartOS raw kernel and boot_archive.

* **images**: This is just a directory, which holds symlinks to all appliances in an `IMGAPI <https://images.joyent.com/docs/>`__-like folder structure.

* **usb**: `Danube Cloud USB images <docs/usb-image.rst>`_.


Requirements
============

Two network-connected Linux/Unix machines are required:

* **buildnode** remote host:
    * A SmartOS/ErigonOS machine that is capable of running KVM and OS virtual machines.
    * Required software:
        * Python 2.7

* **builder** local host:
    * The machine (can be a VM), which has this repository checked out.
    * Required software:
        * git
        * Ansible >= 2.0
        * GNU make
        * sshpass
        * OpenSSH client
        * a working ssh-agent with loaded ``build_ssh_key`` (for running git clone on remote host)
        * a running web server (``build_base_url``)

    * Must have a web root directory ready (``build_base_dir``) and the directory structure must be browsable (autoindex in nginx), e.g.:

        .. code-block:: nginx

            server {
                listen       80;
                server_name  _; 
                root /var/www/html;  # build_base_url

                autoindex on;

                location /images {
                    index manifest;
                    default_type application/json;
                }

                location ~ /images/(.*)/(file|.*.zfs.gz)$ {
                    default_type application/octet-stream;
                }
            }

    * **NOTE**: Building the usb-image target currently requires an ErigonOS/SmartOS machine or a zone with ``fs_allowed`` property set to ``"ufs,pcfs,tmpfs"``.


Configuration
=============

Edit ``etc/hosts.cfg`` and ``etc/config.yml``.

* **etc/hosts.cfg**:
    * Adjust the *builder* and *buildnode* IP addresses and python interpreter.

* **etc/config.yml**:
    * ``build_base_url``
    * ``build_base_dir``
    * ``build_ssh_key`` - the *buildnode* must be accessible from the *builder* machine via SSH.
    * ``build_nic_tag``, ``build_gateway``, ``build_netmask`` and ``build_ips`` - modify according to your network settings.


Usage
=====

.. code-block:: bash

    $ make help

.. make help > docs/make-help.txt

.. include:: docs/make-help.txt
    :code: bash


Links
=====

- Homepage: https://danubecloud.org
- User guide: https://docs.danubecloud.org
- Wiki: https://github.com/erigones/esdc-ce/wiki
- Bug Tracker: https://github.com/erigones/esdc-factory/issues
- Twitter: https://twitter.com/danubecloud
- Mailing list: `danubecloud@googlegroups.com <danubecloud+subscribe@googlegroups.com>`__
- IRC: `irc.freenode.net#danubecloud <https://webchat.freenode.net/#danubecloud>`__


License
=======

::

    Copyright 2016 Erigones, s. r. o.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this project except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

