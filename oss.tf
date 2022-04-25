## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_streaming_stream_pool" "stream_pool" {
  compartment_id = var.compartment_ocid
  name           = var.stream_pool_name
}

resource "oci_streaming_stream" "log_stream" {
  name               = var.stream_name
  partitions         = var.stream_partitions
  retention_in_hours = 24
  stream_pool_id     = oci_streaming_stream_pool.stream_pool.id
}
