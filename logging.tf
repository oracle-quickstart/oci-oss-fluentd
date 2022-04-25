## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_logging_log_group" "fluentd_log_group" {
  count = var.fluentD_output_plugin == "OCI_LOGGING" ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = var.log_group_display_name
}

resource "oci_logging_log" "fluentd_log_source" {
  count = var.fluentD_output_plugin == "OCI_LOGGING" ? 1 : 0
  display_name       = var.log_display_name
  log_group_id       = oci_logging_log_group.fluentd_log_group[0].id
  log_type           = "CUSTOM"
  is_enabled         = true
  retention_duration = "30"
}
