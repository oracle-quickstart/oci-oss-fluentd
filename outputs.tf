## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "generated_ssh_private_key" {
  value     = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : "No Keys Auto Generated"
  sensitive = true
}

output "generated_auth_token" {
  value     = oci_identity_auth_token.auth_token.token
  sensitive = true
}

