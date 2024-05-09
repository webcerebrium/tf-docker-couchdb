resource "docker_container" "couchdb" {
  image   = docker_image.couchdb.image_id
  name    = local.host
  restart = "always"

  log_opts = var.network_params.log_opts

  dynamic "ports" {
    for_each = local.ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }

  networks_advanced {
    name = local.network_id
  }

  labels {
    label = "project"
    value = local.project
  }

  labels {
    label = "host"
    value = local.host
  }

  labels {
    label = "role"
    value = "couchdb"
  }

  mounts {
    read_only = false
    source    = local.volume_exchange
    target    = "/exchange"
    type      = "bind"
  }

  volumes {
    volume_name    = docker_volume.storage.name
    container_path = "/opt/couchdb/data"
  }
}

