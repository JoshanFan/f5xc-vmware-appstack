# f5xc-vmware-appstack

## Overview
Use terraform to deploy VMware app stack cluster on F5 Distributed Cloud.

## Getting Started
The F5 Distributed Cloud terraform modules, you can refer to https://registry.terraform.io/providers/volterraedge/volterra/latest

## Requirements
- vSphere vCenter username and password
- [F5 Distributed Cloud credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials)
    Extract the certificate and the key from the .p12:
```
    openssl pkcs12 -in certificate.p12 -nokeys -out api.crt -nodes
    openssl pkcs12 -in certificate.p12 -nocerts -out api.key -nodes
```