Danube Cloud :: Factory
#######################

This repository is used for building various components of Erigones Danube Cloud, as well as the final Danube Cloud USB key image.


Output
======

All build results are stored in following folders in ``build_base_dir``:

* **appliances**: Danube Cloud appliances (VM images), which then become part of the Danube Cloud USB image:
    * esdc-mon
    * esdc-mgmt
    * esdc-cfgdb
    * esdc-dns
    * esdc-img

* **isos**: ISO images, which are downloaded from external sources and become part of the Danube Cloud USB image.

* **archives**: Tarballs, which become part of the Danube Cloud USB image (/opt):
    * local
    * monitoring
    * esdc-node

* **platform**: Tarballs, which contain hypervisor platform - SmartOS raw kernel and boot_archive.

* **images**: This is just a directory, which holds symlinks to all appliances in an `IMGAPI <https://images.joyent.com/docs/>`__-like folder structure.

* **usb**: Danube Cloud USB images.


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

    * **NOTE**: Building the usb-image target currently requires an ErigonOS/SmartOS machine or zone with ``fs_allowed`` property set to ``"ufs,pcfs,tmpfs"``.


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

        **** Danube Cloud   Assembly Line ****

        Please use 'make <target>' where <target> is one of:

        init         initialize the builder directory structure
        check        examine the builder directory structure and HTTP access
        archives     download hypervisor OS archives
        isos         download iso images 
        platform     download hypervisor platform archive
        usb-deps     download archives, isos and platform
        usb-image    build USB image
        imgapi-tree  rebuild the IMGAPI tree
        clean        delete all appliance VMs and their base images in reverse order
        clean-<app>  delete appliance VM and its base image
        all          build all appliances/images
        base         build all base appliances (base-centos-6 base-centos-7 base-64-es centos-6 centos-7)
        esdc         build all Danube Cloud appliances (esdc-mon, esdc-mgmt, esdc-cfgdb, esdc-dns, esdc-img, esdc-node)
        <app>        build an appliance/image, one of:

            base-centos-6
            base-centos-7
            base-64-es
            centos-6
            centos-7
            esdc-mon
            esdc-mgmt
            esdc-cfgdb
            esdc-dns
            esdc-img
            esdc-node

            NOTE: The build order is rather important.

        Following environment variables will change the build behaviour:

        VERSION      build a specific version of an appliance (default: current YYYYMMDD)
        VERBOSE      make ansible more verbose
        EXTRA_VARS   override ansible variables
            - usb_type={hn,cn}  (default: hn)
            - release_edition={ce,ee}  (default: ce)


Links
=====

- Homepage: https://danubecloud.org
- Wiki: https://github.com/erigones/esdc-ce/wiki
- Bug Tracker: https://github.com/erigones/esdc-factory/issues
- Twitter: https://twitter.com/danubecloud


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

