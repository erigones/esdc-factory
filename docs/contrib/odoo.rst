Danube Cloud :: Factory :: Appliances :: Odoo
#############################################

`Odoo <https://www.odoo.com/>`__ LX Zone image for `Danube Cloud <https://danubecloud.org>`__.

Odoo package is installed on minimal `Debian 9` virtual machine with support for initialization through metadata.

The image supports following metadata:

* **odoo_admin_passwd**: master password that protects web interface configuration on initial setup page. If not present, `admin_passwd` is not configured in `odoo.conf`.
* **root_authorized_keys**: content for ``/root/.ssh/authorized_keys``. Added automatically by Danube Cloud.
* **hostname**: FQDN hostname that is to be configured as an OS hostname and also as nginx reverse proxy SSL host. Added automatically by Danube Cloud.
* **user-script**: shell commands to be executed at first boot. Added automatically by Danube Cloud.

During deploy a self-signed openssl certificate is created. You can find it in `/etc/nginx/ssl/`.

.. note:: Odoo instance without a loadballancer is listening at `0.0.0.0:8069`. Secure it if necessary.

Changelog
---------

20191201
~~~~~~~~

- Odoo 12.0
- Wkhtmltopdf 0.12.5-1
- PostgreSQL 12.1

