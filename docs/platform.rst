Danube Cloud :: Factory :: Platform
###################################

Danube Cloud hypervisor platform - SmartOS raw kernel and boot_archive.

The build procedure requires It can be built either on **SmartOS** or on **Danube Cloud** node.

Requirements
------------

The build procedure requires either a **SmartOS** or a **Danube Cloud** node.
You will need **base-64-lts** zone version **18.4.0** (UUID **c193a558-1d63-11e9-97cf-97bb3ee5c14f**) and development tools inside the zone.

The process
-----------

Creating a build zone
~~~~~~~~~~~~~~~~~~~~~

Danube Cloud (and SmartOS) is built inside a zone. For the zone to be created, you need to verify that you have Joyent package source configured in **imgadm**:

::

    # imgadm sources

You should see the output similar to following:

::

    # imgadm sources
    https://images.joyent.com

If you do not have *images.joyent.com* source configured, just add it (at this step you will need to have working Internet connection):

::

    # imgadm sources -a https://images.joyent.com/

Now the **base-64-lts** version **18.4.0** can be imported:

::

    # imgadm import c193a558-1d63-11e9-97cf-97bb3ee5c14f

Then you can create a *joyent*-branded VM inside your node (as mentioned above, either SmartOS or Danube Cloud) like following:

::

    {
      "autoboot": true,
      "brand": "joyent",
      "fs_allowed": "ufs,pcfs,tmpfs,lofs",
      "image_uuid": "c193a558-1d63-11e9-97cf-97bb3ee5c14f",
      "tmpfs": 8192,
      "hostname": "dc-build",
      "dns_domain": "in.example.com",
      "resolvers": [
        "8.8.8.8"
      ],
      "alias": "dc",
      "nics": [
        {
          "interface": "net0",
          "nic_tag": "admin",
          "gateway": "172.18.0.1",
          "gateways": [
            "172.18.0.1"
          ],
          "netmask": "255.255.255.0",
          "ip": "172.18.0.111",
          "ips": [
            "172.18.0.111/24"
          ],
          "allow_ip_spoofing": true,
          "primary": true
        }
      ]
    }

Once you have the VM ready, you can either **zlogin** or **ssh** into it.

Useful hints:

-  Use machine with at least 4 cores
-  Build zone should have at least 8G RAM
-  Build zone should have at least 40G virtual disk (you can resize using **zfs set ...** later)
-  Build zone should have working Internet connection


Customizing zone settings
~~~~~~~~~~~~~~~~~~~~~~~~~

When you successfully deployed your build zone and logged into it, you are advised to:

Create a build user (non-root)

::

    # groupadd builder
    # useradd -d /home/builder -m -s /bin/bash -c 'Builder' -g builder builder
    # passwd builder

Make the user "Primary Administrator" (to allow **pfexec su -** work)

::

    # usermod -P "Primary Administrator" builder

Install bootstrap tools

::

    # pkgin up
    # pkgin in git

Getting the source code
-----------------------

For Danube Cloud working directory you will need at least 40G of disk space (see above.)

Bootstrap the working directory with source code checkout the newest branch and (if needed) update appropriate source branches in `default.configure-projects`:

-  `erigones/smartos-live <https://github.com/erigones/smartos-live>`__

We do it like this:

::

    $ mkdir dc
    $ cd dc
    $ git clone https://github.com/erigones/smartos-live.git smartos-live
    $ cd smartos-live
    $ git checkout new_release_20191010
    $ vim default.configure-projects
    $ ./configure

**configure** will download and install all the packages and sources required for further build steps.

Build process
-------------

Build process is quite straightforward: You just need to run several **gmake** commands according to the target you want to achieve. In order to build Danube Cloud platform and boot images, following steps are to be taken:

::

    $ gmake live |& tee -a .gmakelive-out.txt

After several hours, the process should finish. Check log files (their location will be displayed in the meantime).

Resulting images will be under **output/** directory. Platform image will have the name of **platform-\ *buildstamp*.tgz** and boot image will be **boot-\ *buildstamp*.tgz**.

You can parametrize the resulting filenames using two environment variables:

-  INTERIM\_RELEASE
-  VERSION\_ADDENDUM
-  MAX\_JOBS

If **INTERIM\_RELEASE** is set to a value other than *empty* or **0**, resulting filenames will have format **platform-\ *branch*-*fullcommithash*.tgz** and **boot-\ *branch*-*fullcommithash*.tgz**. Setting **VERSION\_ADDENDUM** will additionally append **+\ *${VERSION\_ADDENDUM}*** to the end of the file name (either with or without **INTERIM\_RELEASE**).

Variable **MAX\_JOBS** controls how many *gmake* processes will be spawned. For zones with less than 16GB of memory, default is **8** and for zones with more memory, default is **128**. Setting this manually will override the default.
