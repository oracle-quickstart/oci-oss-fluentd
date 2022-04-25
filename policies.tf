## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_dynamic_group" "fluentd_dynamic_group" {
    provider = oci.homeregion
    compartment_id = var.tenancy_ocid
    description = "Group of fluentd instances"
    matching_rule = "ANY {instance.compartment.id='${var.compartment_ocid}'}"
    name = "fluentd_instances"

}

resource "oci_identity_policy" "fluentd_policies" {
  provider       = oci.homeregion
  compartment_id = var.compartment_ocid
  name           = "fluentd_policies"
  description    = "Policy to provide access to fluentd instances to read from OSS and write logging"
  statements     = [
    
    "Allow dynamic-group fluentd_instances to {STREAM_READ, STREAM_CONSUME} in compartment id ${var.compartment_ocid} where all { target.stream.id = '${oci_streaming_stream.log_stream.id}', request.principal.compartment.id = '${var.compartment_ocid}' } ",
    "Allow dynamic-group fluentd_instances to use log-content in compartment id ${var.compartment_ocid}"
  ]
}
