// Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


data "oci_identity_user" "current_user" {
    provider = oci.homeregion
    user_id = var.current_user_ocid
}

data "oci_identity_tenancy" "current_user_tenancy" {
    provider = oci.homeregion
    tenancy_id = var.tenancy_ocid
}

resource "oci_identity_auth_token" "auth_token" {
    provider = oci.homeregion
    description = "Token to connect to streams."
    user_id = var.current_user_ocid
}