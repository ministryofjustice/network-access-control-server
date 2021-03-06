# Attribute Validation

The FreeRADIUS server accepts request/response attributes as part of policies and MAC authorisation.

The [admin portal](https://github.com/ministryofjustice/network-access-control-admin) allows an
administrator to add a rule (request) and/or a response.
As part of a rule/response, an attribute must be specified, however in order to minimise human error,
the admin portal is developed to validate the attributes against the FreeRADIUS dictionaries.

## FreeRADIUS Dictionaries

The FreeRADIUS dictionaries can be found in the server (`/usr/share/freeradius/`).
These dictionaries are copied to an AWS S3 bucket, for example `mojo-development-nac-config-bucket`,
from a single AWS ECS task by executing the [`publish_dictionaries`](/scripts/publish_dictionaries.sh)
script.

In the case where the FreeRADIUS server is upgraded to a newer version, the above-mentioned script
ensures the latest dictionaries are always present in the AWS S3 bucket.

![publish radius dictionaries diagram](./diagrams/NAC-RADIUS-Attribute-Validation.drawio.svg)

## Attributes

The attributes have been split into default and custom (vendor specific) attributes.

### Request attributes

The default request attributes can be found in
[RFC 2865](https://datatracker.ietf.org/doc/html/rfc2865).

Additional default attributes for `EAP-TLS` are as follows:

```
TLS-Cert-Serial
TLS-Cert-Expiration
TLS-Cert-Issuer
TLS-Cert-Subject
TLS-Cert-Common-Name
TLS-Cert-Subject-Alt-Name-Email
TLS-Cert-Subject-Alt-Name-Dns
TLS-Cert-Subject-Alt-Name-Upn
TLS-Client-Cert-Serial
TLS-Client-Cert-Expiration
TLS-Client-Cert-Issuer
TLS-Client-Cert-Subject
TLS-Client-Cert-Common-Name
TLS-Client-Cert-Filename
TLS-Client-Cert-Subject-Alt-Name-Email
TLS-Client-Cert-X509v3-Extended-Key-Usage
```

### Response attributes

The default list of response attributes can be found here:
https://freeradius.org/rfc/attributes.html

FreeRADIUS maintains a dynamic retrieval of response attributes in the link above, ensuring they
are always up-to-date with the latest FreeRADIUS version. However, the entire list is not required
for the server because some modules are not enabled, such as the accounting module. This means the
admin portal will only display the supported response attributes.

### Custom attributes

The FreeRADIUS dictionary files contain the default list of attributes as well as a list of
attributes that are vendor specific. 

## Validation

The [Network Access Control Service Admin](https://github.com/ministryofjustice/network-access-control-admin)
application runs a Rake task
([`radius_attributes:fetch`](https://github.com/ministryofjustice/network-access-control-admin/blob/main/lib/tasks/radius_attributes.rake))
before running the Rails server as can be seen in the
[Dockerfile](https://github.com/ministryofjustice/network-access-control-admin/blob/main/Dockerfile).

This Rake task fetches the FreeRADIUS dictionary files from the AWS S3 bucket and outputs them into the `/usr/share/freeradius/` folder.

The request and response attributes and values are validated against the dictionaries by booting FreeRADIUS, checking the configuration and exiting immediately. The attribute validator uses the [FreeRADIUS parse errors to generate descriptive error messages](https://github.com/ministryofjustice/network-access-control-admin/blob/main/spec/use_cases/validate_radius_attribute_spec.rb) when an administrator enters invalid values using the Network Access Control Service Admin application.
