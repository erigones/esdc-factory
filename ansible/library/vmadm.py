#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# © 2014, Hugo Silva <freebsd.consulting@gmail.com>
import json
import os
import hashlib
# Ansible boilerplate
from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = '''
---
module: vmadm
author: Hugo Silva
version_added: 1.8.2
short_description: Manage SmartOS virtual machines
description:
    -  The vmadm tool allows you to interact with virtual machines on a
       SmartOS system. All 3 of: OS Virtual Machines (SmartOS zones), LX
       Virtual Machines and KVM Virtual Machines can be managed. vmadm allows
       you to create, inspect, modify and delete virtual machines on the local
       system.

options:
    state:
        required: true
        choices: [present, absent, rebooted, started, stopped, updated]
        description:
        - which state the virtual machine should be in
    uuid:
        required: false
        description:
        - virtual machine uuid (either this or alias)
    alias:
        required: false
        description:
        - virtual machine alias (either this or uuid)
    manifest:
        required: false
        description:
        - a valid json file for create/update
    proplist:
        required: false
        description:
        - a k=v whitespace-separated list to pass to vmadm update
'''

EXAMPLES = '''
# Create a vm
- vmadm: manifest=/opt/custom/zones/webserver.json state=present

# Start a previously created vm (by alias)
- vmadm: alias=webserver state=started

# Start a previously created vm (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 state=started

# Stop a previously created vm (by alias)
- vmadm: alias=webserver state=stopped

# Stop a previously created vm (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 state=stopped

# Reboot a vm (by alias)
- vmadm: alias=webserver state=rebooted

# Reboot a vm (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 state=rebooted

# Update a vm, using a property list (by alias)
- vmadm: alias=webserver proplist='ram=256 quota=64' state=updated

# Update a vm, using a property list (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 proplist='ram=256 quota=64' state=updated

# Update a vm, using payload from a json file (by alias)
- vmadm: alias=webserver manifest=/tmp/update.json state=updated

# Update a vm, using payload from a json file (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 manifest=/tmp/update.json state=updated

# Delete a VM (by alias)
- vmadm: alias=webserver state=absent

# Delete a VM (by uuid)
- vmadm: uuid=e19429c2-f412-4210-b0cf-5ed59b81b8f1 state=absent
'''


def check_subparam(module, subparam, params, state):
    if not params.get(subparam, False):
        module.fail_json(msg="%s subparam required when state=%s" % (subparam, state))


def vmadm_alias_lookup(module, vmadm_path, vm_alias):
    rc, so, se = module.run_command('%s lookup alias=%s' % (vmadm_path, vm_alias))

    if len(so) == 0:
        return None
    else:
        return so


def vmadm_get_vm_json_description(module, vmadm_path, uuid):
    rc, so, se = module.run_command('%s get %s' % (vmadm_path, uuid))

    if rc != 0:
        module.fail_json(msg="vmadm_get_vm_json_description(): failed to get json description for uuid %s" % uuid)

    return str(json.loads(so, object_hook=strip_keys_from_json))


def open_and_load_json_data(module, manifest):
    try:
        json_data = open(manifest, 'r')
    except IOError as exc:
        module.fail_json(msg="could not open %s for reading: %s" % (manifest, exc))

    try:
        # noinspection PyUnboundLocalVariable
        return json.load(json_data)
    except Exception as exc:
        module.fail_json(msg="could not parse json in manifest file: %s (%s)" % (manifest, exc))


def strip_keys_from_json(payload):
    strip_keys = ['last_modified']

    for key in payload:
        if key in strip_keys:
            del payload[key]

    return payload


def main():
    module = AnsibleModule(
        argument_spec=dict(
            state=dict(choices=['present', 'absent', 'rebooted', 'started', 'stopped', 'updated'],
                       type='str', required=True),
            uuid=dict(default=None, aliases=['name'], type='str', required=False),
            alias=dict(default=None, type='str', required=False),
            manifest=dict(default=None, type='str', required=False),
            proplist=dict(default=None, type='str', required=False)
        ),
        mutually_exclusive=[['alias', 'uuid'], ['proplist', 'manifest']]
    )

    # set some useful variables
    vmadm_path = module.get_bin_path('vmadm', required=True)
    p = module.params
    changed = False
    state, uuid, alias, manifest, proplist = p["state"], p["uuid"], p["alias"], p["manifest"], p["proplist"]
    rc, so, se = 1, "", ""

    # vmadm create -f $manifestFile
    if state == 'present':

        # extra parameter sanity checks (we ignore uuid and alias, as they do nothing here.)
        check_subparam(module, 'manifest', p, state)

        # abort if we can't find the vm manifest file.
        if not os.path.isfile(manifest):
            module.fail_json(msg="could not locate manifest file: %s" % manifest)

        # we need to delve into the manifest and find the alias for the VM, and then
        # make sure that there is not a VM with that alias (even though SmartOS doesn't
        # care about duplicated aliases).
        # Otherwise, a new VM is created each and every single time (not idempotent).
        data = open_and_load_json_data(module, manifest)

        try:
            vm_alias = data["alias"]
        except KeyError:
            module.fail_json(msg="manifest file must provide an alias for the vm")
        else:
            if not vmadm_alias_lookup(module, vmadm_path, vm_alias):
                rc, so, se = module.run_command('%s create -f %s' % (vmadm_path, manifest))
                changed = True
            else:
                rc = 0

    else:
        # -- common checks/tasks for all states except 'present'
        if not uuid and not alias:
            module.fail_json(msg="one of 'alias' or 'uuid' required when state is not 'present'")

        if alias:
            uuid = vmadm_alias_lookup(module, vmadm_path, alias)
            if not uuid:
                module.fail_json(msg="could not locate a matching uuid for vm alias '%s'" % alias)
        # --

        # handles most other states.
        if state in ('started', 'stopped', 'rebooted', 'absent'):
            if state == 'absent':
                subcommand = 'delete'
            else:
                subcommand = state.strip('ed').replace('opp', 'op')
            rc, so, se = module.run_command('%s %s %s' % (vmadm_path, subcommand, uuid))

            # detect whether the state was changed.
            # NOTE: oddly enough, it uses stderr here (2014/Dec/25)
            if se.find("Successfully") == 0:
                changed = True

        elif state == 'updated':
            if not proplist and not manifest:
                module.fail_json(msg="one of 'manifest' or 'proplist' required when state='updated'")

            # In order to be idempotent, we need to compare the values that we're being asked to update
            # against the values stored in the hypervisor.
            vm_json_hash = hashlib.sha1(vmadm_get_vm_json_description(module, vmadm_path, uuid)).hexdigest()

            if proplist:
                rc, so, se = module.run_command('%s update %s %s' % (vmadm_path, uuid, proplist))
            else:  # manifest
                rc, so, se = module.run_command('%s update %s -f %s' % (vmadm_path, uuid, manifest))

            vm_json_newhash = hashlib.sha1(vmadm_get_vm_json_description(module, vmadm_path, uuid)).hexdigest()

            if rc == 0:
                if vm_json_hash == vm_json_newhash:
                    changed = False
                    rc, so, se = (0, "", "")
                else:
                    changed = True

    # exit cleanly.. or not.
    if rc != 0:
        module.fail_json(msg=se)
    else:
        module.exit_json(changed=changed, msg=so)


if __name__ == '__main__':
    main()
