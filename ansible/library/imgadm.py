#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# © 2014, Hugo Silva <freebsd.consulting@gmail.com>
# Ansible boilerplate
from ansible.module_utils.basic import BOOLEANS, BOOLEANS_TRUE, AnsibleModule

DOCUMENTATION = '''
---
module: imgadm
author: Hugo Silva
version_added: 1.8.2
short_description: Manage SmartOS VM images
description:
    -  The imgadm tool allows you to interact with virtual machine images on a
       SmartOS system. Virtual machine images (also sometimes referred to as
       'datasets') are snapshots of pre-installed virtual machines which are
       prepared for generic and repeated deployments.
options:
    command:
        required: true
        choices: [sources, import, update]
        description:
        - which subcommand to run
    url:
        required: false
        description:
        - url for a imgapi server (used for 'sources')
    state:
        required: false
        choices: [present, absent]
        default: 'present'
        description:
        - describe the desired state
    uuid:
        required: false
        aliases: ['name']
        description:
        - uuid of the dataset to import/update/delete
    zpool:
        required: false
        default: 'zones'
        description:
        - an alternative zpool name. used for importing/deleted
    update:
        required: false
        description:
        default: no
        choices: [yes, no, true, false, 1, 0, True, False]
        description:
        - update image list, or optionally a single image. Used with command='image'
'''

EXAMPLES = '''
# Install base64 14.3.0 image
- imgadm: command=image uuid=62f148f8-6e84-11e4-82c5-efca60348b9f

# Delete base64 14.3.0 image
- imgadm: command=image uuid=62f148f8-6e84-11e4-82c5-efca60348b9f state=absent

# Update base64 14.3.0 image
- imgadm: command=image uuid=62f148f8-6e84-11e4-82c5-efca60348b9f update=yes

# Update ALL images
- imgadm: command=image update=yes

# Add a new image source
- imgadm: command=sources url=http://datasets.at/

# Delete a image source
- imgadm: command=sources url=http://datasets.at/ state=absent
'''


def check_subparam(module, subparam, params, command):
    if not params.get(subparam, False):
        module.fail_json(msg="%s subparam required for command %s" % (subparam, command))


def main():
    module = AnsibleModule(
        argument_spec=dict(
            command=dict(choices=['sources', 'image'], type='str', required=True),
            url=dict(default=None, type='str', required=False),
            state=dict(default='present', choices=['present', 'absent'], required=False),
            uuid=dict(default=None, aliases=['name'], type='str', required=False),
            zpool=dict(default='zones', type='str', required=False),
            update=dict(default='no', choices=BOOLEANS, type='bool', required=False)
        )
    )

    # set some useful variables
    imgadm_path = module.get_bin_path('imgadm', required=True)
    p = module.params
    changed = False
    cmd, state = p["command"], p.get("state", None)
    rc, so, se = 1, "", ""

    # handles adding/removing image sources.
    if cmd == 'sources':
        [check_subparam(module, check_this, p, cmd) for check_this in ('url', 'state')]

        # run imgadm with -a/-d depending on what the desired state is.
        if state == 'present':
            rc, so, se = module.run_command('%s sources -a %s' % (imgadm_path, p["url"]))

        elif state == 'absent':
            rc, so, se = module.run_command('%s sources -d %s' % (imgadm_path, p["url"]))

        if so.split()[0] in ("Added", "Deleted") and rc == 0:
            changed = True

    # handles importing/delete images to/from the system
    if cmd == 'image':
        uuid = p.get("uuid", None)

        if state == 'present':

            # are we updating ? and if yes, is it an image or the whole list?
            if p["update"] in BOOLEANS_TRUE:
                if uuid:
                    rc, so, se = module.run_command('%s update %s' % (imgadm_path, uuid))
                else:
                    rc, so, se = module.run_command('%s update' % imgadm_path)
            else:
                check_subparam(module, 'uuid', p, cmd)
                rc, so, se = module.run_command('%s import -q %s' % (imgadm_path, p["uuid"]))

        elif state == 'absent':
            rc, so, se = module.run_command('%s delete %s' % (imgadm_path, p["uuid"]))

        if so.find("Imported image") > 0 or so.find("Deleted image") == 0 or so.find("Updated") == 0:
            changed = True

    # exit cleanly.. or not.
    if rc != 0:
        module.fail_json(msg=se)
    else:
        module.exit_json(changed=changed, msg=so)


if __name__ == '__main__':
    main()

# XXX: to implement:
#   - support -P altpoolname
#   - support imgadm install
