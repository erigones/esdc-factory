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
    * opt-custom
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
        * Python 2.7+

* **builder** local host:
    * The machine (can be a VM), which has this repository checked out.
    * Required software:
        * git
        * Ansible >= 2.3
        * GNU make (gmake)
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


Create build environment
========================

Create builder VM (on plain SmartOS or on Danube Cloud):

* It is recommended to use the same image that is used for building official SmartOS: ``base-64-lts 18.4.0`` with UUID ``c193a558-1d63-11e9-97cf-97bb3ee5c14f``. But you can use any SunOS image, just follow the requirements for **builder** from previous sections. This sections will describe the recommended setup.
* 8 GB RAM, at least 20GB of disk space. Use of `ZLE` disk compression is recommended.
* Add a delegated dataset (optional, for builds speed up)
* Modify `fs_allowed`` property from the global zone:

    .. code-block:: shell
    
        vmadm update <vm_uuid> fs_allowed="ufs,pcfs,tmpfs"
        vmadm reboot <vm_uuid>

* Log into the VM and set up packages (as root user):

    .. code-block:: shell

        pkgin up
        pkgin fug
        pkgin in git gmake ansible nginx
        ssh-keygen -t ecdsa
        mkdir /data
        cd /data        # this is build_base_dir
        git clone https://github.com/erigones/esdc-factory.git
        cd esdc-factory/etc
        cp config.sample.yml config.yml
        cp hosts.sample.cfg hosts.cfg
        cd ..

* edit ``etc/config.yml``:

  * ``build_base_url`` - use the IP address of this builder VM (e.g. `http://10.111.10.206`)
  * ``build_base_dir`` - `/data` by default
  * ``build_ssh_key`` - content of ``~/.ssh/id_ecdsa.pub`` on the builder VM. This ssh key needs to be pushed to buildnode (SmartOS global zone).
  * ``build_ip`` - IP address of a temporary VM that will be created during image builds
  * ``build_gateway``, ``build_netmask``, ``build_nic_tag``, ``build_vlan_id`` - network settings that will be used by temporary VMs during image builds

* edit ``etc/hosts.yml``:

  * edit IP address of ``buildnode`` (SmartOS global zone that will be used for creating VMs)

* push ssh public key from ``~/.ssh/id_ecdsa.pub`` to the buildnode's ``/root/.ssh/authorized_keys`` so the `buildnode` VM can access the `builder` without a password

* configure and enable nginx on the ``buildnode`` VM. You can find the sample nginx config in ``etc/nginx.conf.sample``:

    .. code-block:: shell

        cp -f /data/esdc-factory/etc/nginx.conf.sample /opt/local/etc/nginx/nginx.conf
        svcadm enable nginx
        svcs nginx

* initialize factory on builder VM

    .. code-block:: shell

        cd /data/esdc-factory
        eval `ssh-agent -s`
        ssh-add
        gmake init


Usage
=====

.. code-block:: bash

    $ make help

Examples (more examples are in `make help`):

.. code-block:: bash

    $ eval `ssh-agent -s`
    $ ssh-add
    $ make base-64-es
    $ make base-centos-7
    $ make archives
    $ make isos
    $ make platform     # this needs setup of smartos compile environment
    $ make esdc
    $ env EXTRA_VARS="usb_type=cn" gmake usb-image
    $ env EXTRA_VARS="usb_type=hn" gmake usb-image


** See also: docs/make-help.txt


Parallel builds
===============

If you want to use parallel builds, you need to specify multiple temporary IPs and multiple VNC ports so the VMs won't create collisions. Define ``build_ips`` and ``build_vnc_ports`` dicts with names of future temporary VMs as keys. See example in config file.


Compilation of Danube Cloud platform
====================================

To build complete USB image, you need to compile the platform (based on slightly modified SmartOS).

.. code-block:: bash

    # useradd -g 1 -s /bin/bash -d /data/compile -m compile
    # usermod -P 'Primary Administrator' compile
    # su - compile
    $ git clone git://github.com/erigones/smartos-live
    $ cd smartos-live/
    $ git branch -av | grep new_release
    $ git checkout new_release_20201105     # choose the newest one
    $ ./configure
    $ gmake live

This has enabled you to use ``make platform`` command from `esdc-factory`.


Links
=====

- Homepage: https://danube.cloud
- User guide: https://docs.danube.cloud
- Wiki: https://github.com/erigones/esdc-ce/wiki
- Bug Tracker: https://github.com/erigones/esdc-factory/issues
- Twitter: https://twitter.com/danubecloud
- Gitter: https://gitter.im/erigones/DanubeCloud

- More info: https://github.com/erigones/esdc-ce/wiki/Building-Danube-Cloud


License
=======

::

    Copyright 2016-2020 Erigones, s. r. o.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this project except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

