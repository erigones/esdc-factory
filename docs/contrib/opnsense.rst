Danube Cloud :: Factory :: Appliances :: OPNSense
#################################################

`OPNSense <https://opnsense.org>`__ image for `Danube Cloud <https://www.danube.cloud>`__ or `SmartOS <https://wiki.smartos.org>`__ with possibility to pre-seed initial OPNSense configuration (represented by ``config.xml``) by using metadata.

The image supports following metadata:

* **config.xml**: if defined, content of this variable will be placed as ``/conf/config.xml`` at first boot by modified OPNSense configuration importer.


**Note:** You can also use ``config.xml`` file that was exported from another OPNSense installation.

**Note:** All newlines in ``config.xml`` metadata variable need to be converted to `\n`. Danube Cloud GUI does this automatically.


Deploy within Danube Cloud
==========================

Create a new VM of type ``BSD VM``, add uplink as a first network interface and set disk image to opnsense (downloaded from Danube Cloud repo). Then ``Edit`` VM preferrences, click ``Show advanced settings``, add new metadata item of name ``config.xml`` and paste the plaintext content of your ``config.xml``. The newlines will be converted automatically.

Deploy without Danube Cloud
===========================

Without DC, you have to create a json manifest for a new VM. You might find useful `this VM template <https://github.com/erigones/esdc-factory/blob/master/ansible/templates/usb/zones/opnsense.vmmanifest.j2>`__ as an example on how to create VM. Just edit it to suit your needs and replace ``@placeholders@`` by your data.
Please note that `config.xml` metadata item needs to have escaped newlines and quotes (").

Example escaping:

``> ESCAPED_CONF_XML="$(awk -v ORS='\\\\n' '1' unescaped-config.xml | sed -e 's/"/\\\\"/g')"``

``> sed -e "s|@CONFIG_XML@|${ESCAPED_CONF_XML}|" vm_template.json > opnsense.json``

``> json --validate -q -f opnsense.json &> /dev/null || echo Validation failed``


How to generate custom config seed from scratch
===============================================

You can get inspiration from `this config.xml <https://github.com/erigones/esdc-factory/blob/master/ansible/files/opnsense/config.xml.tmpl>`__ that is used internally by Danube Cloud installer to deploy OPNSense. It is jinja-templated and you can use `j2` tool (`j2cli` pip module) to template it. You can get template seed variables `from here <https://github.com/erigones/esdc-factory/blob/master/ansible/files/opnsense/config-seed-vars.j2.tmpl>`__.

How to do proper templating: fill the template seed variable by your parameters, optionally edit template `config.xml.tmpl` to suit you needs (you might want to remove the port forwards for mgmt01 and dns01 appliances) and then issue:

``> pip install j2cli``
``> j2 -f json config.xml.tmpl config-seed-vars.j2.tmpl > config.xml``


Finally place the generated config.xml contents into VM metadata (see above in this document).

**Note:** Please note that variables ``web_ssl_cert_b64`` and ``web_ssl_key_b64`` need to be base64 encoded. Use command ``cat CERT.pem | base64 -w 0 > CERT_B64.txt`` to do the conversion.


Changelog
---------

20200816
~~~~~~~~

- OPNSense version 20.7
