## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "fluentd_config_ocilogging" {

  count = var.fluentD_output_plugin == "OCI_LOGGING" ? 1 : 0

  depends_on = [oci_core_instance.compute_instance, oci_streaming_stream.log_stream]

  template = file("./config/fluentd_ocilogging.config")

  vars = {
    REGION        = var.region
    TENANCY_NAME  = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME     = data.oci_identity_user.current_user.name
    AUTH_CODE     = oci_identity_auth_token.auth_token.token
    STREAM_POOL   = oci_streaming_stream_pool.stream_pool.id
    LOG_OBJECT_ID = oci_logging_log.fluentd_log_source[0].id
  }
}

data "template_file" "fluentd_config_datadog" {

  count = var.fluentD_output_plugin == "DATA_DOG" ? 1 : 0

  depends_on = [oci_core_instance.compute_instance, oci_streaming_stream.log_stream]

  template = file("./config/fluentd_datadog.config")

  vars = {
    REGION           = var.region
    TENANCY_NAME     = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME        = data.oci_identity_user.current_user.name
    AUTH_CODE        = oci_identity_auth_token.auth_token.token
    STREAM_POOL      = oci_streaming_stream_pool.stream_pool.id
    DATA_DOG_API_KEY = var.data_dog_api_key
  }
}

data "template_file" "fluentd_config_newrelic" {

  count = var.fluentD_output_plugin == "NEW_RELIC" ? 1 : 0

  depends_on = [oci_core_instance.compute_instance]

  template = file("./config/fluentd_newrelic.config")

  vars = {
    REGION           = var.region
    TENANCY_NAME     = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME        = data.oci_identity_user.current_user.name
    AUTH_CODE        = oci_identity_auth_token.auth_token.token
    STREAM_POOL      = oci_streaming_stream_pool.stream_pool.id
    NEW_RELIC_API_KEY = var.new_relic_api_key
  }
}

data "template_file" "fluentd_config_dynatrace" {

  count = var.fluentD_output_plugin == "DYNA_TRACE" ? 1 : 0

  depends_on = [oci_core_instance.compute_instance]

  template = file("./config/fluentd_dynatrace.config")

  vars = {
    REGION           = var.region
    TENANCY_NAME     = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME        = data.oci_identity_user.current_user.name
    AUTH_CODE        = oci_identity_auth_token.auth_token.token
    STREAM_POOL      = oci_streaming_stream_pool.stream_pool.id
    DYNA_TRACE_API_KEY = var.dyna_trace_api_key
    DYNA_TRACE_HOST_NAME = var.dyna_trace_host_name
  }
}

data "template_file" "fluentd_config_elasticsearch" {

  count = var.fluentD_output_plugin == "ELASTIC_SEARCH" ? 1 : 0

  depends_on = [oci_core_instance.compute_instance]

  template = file("./config/fluentd_elasticsearch.config")

  vars = {
    REGION           = var.region
    TENANCY_NAME     = data.oci_identity_tenancy.current_user_tenancy.name
    USER_NAME        = data.oci_identity_user.current_user.name
    AUTH_CODE        = oci_identity_auth_token.auth_token.token
    STREAM_POOL      = oci_streaming_stream_pool.stream_pool.id
    ES_HOST          = var.es_host
    ES_PORT          = var.es_port
    ES_USER          = var.es_username
    ES_PASS          = var.es_pass
  }
}


resource "null_resource" "run_scripts" {

  depends_on = [oci_core_instance.compute_instance]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance.public_ip
      private_key = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : file(var.private_ssh_key_path)
      agent       = false
      timeout     = "10m"
    }
    content     = var.fluentD_output_plugin == "OCI_LOGGING" ? data.template_file.fluentd_config_ocilogging[0].rendered : (var.fluentD_output_plugin == "DATA_DOG" ? data.template_file.fluentd_config_datadog[0].rendered : (var.fluentD_output_plugin == "NEW_RELIC" ? data.template_file.fluentd_config_newrelic[0].rendered : (var.fluentD_output_plugin == "DYNA_TRACE" ? data.template_file.fluentd_config_dynatrace[0].rendered : data.template_file.fluentd_config_elasticsearch[0].rendered) ) )
    destination = "/home/opc/td-agent.conf"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = oci_core_instance.compute_instance.public_ip
      private_key = var.generate_public_ssh_key ? tls_private_key.public_private_key_pair.private_key_pem : file(var.private_ssh_key_path)
      agent       = false
      timeout     = "10m"
    }

    inline = [
      "sudo curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh",
      "sudo td-agent-gem install fluent-plugin-kafka -v 0.17.5 --no-document",
      "sudo td-agent-gem install fluent-plugin-oci-logging --no-document",
      "sudo td-agent-gem install fluent-plugin-datadog --no-document",
      "sudo td-agent-gem install fluent-plugin-newrelic --no-document",
      "sudo td-agent-gem install fluent-plugin-dynatrace --no-document",
      "sudo td-agent-gem install fluent-plugin-elasticsearch --no-document",
      "sudo mv /etc/td-agent/td-agent.conf /etc/td-agent/td-agent.conf.backup",
      "sudo mv /home/opc/td-agent.conf /etc/td-agent/td-agent.conf",
      "sudo systemctl start td-agent.service",
      "sleep 5"
    ]
  }
}
