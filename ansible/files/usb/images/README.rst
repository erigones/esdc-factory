Bootable USB image
##################


.. code-block:: bash
    mkdir -p /tmp/usb
    mkfile -n 2000000000 /tmp/usb.img
    lofidev=$(lofiadm -a /tmp/usb.img)
    fdisk ${lofidev/lofi/rlofi}
    echo "y"| mkfs  -F pcfs -o fat=32,b=ESDC ${lofidev/lofi/rlofi/}:c
    mount -F pcfs -o foldcase,noatime $lofidev:c /tmp/usb

    BUILDSTAMP=$(cat /zones/389e1e35-4391-4109-a152-7a4db11bda72/data/smartos-live/output/buildstamp)
    gtar xf /zones/389e1e35-4391-4109-a152-7a4db11bda72/data/smartos-live/output/boot-${BUILDSTAMP}.tgz -C /tmp/usb
    cp /zones/389e1e35-4391-4109-a152-7a4db11bda72/data/smartos-live/proto/boot/grub/stage2_eltorito /tmp/usb/boot/grub

    grub --batch << _ENDOFGRUBCOMMANDS_
    device (hd0) /tmp/usb.img
    root (hd0,0)
    setup (hd0)
    quit
    _ENDOFGRUBCOMMANDS_

    cd /
    sync

    umount /tmp/usb
    lofiadm -d ${lofidev}
    pigz -9 -v /tmp/usb.img
