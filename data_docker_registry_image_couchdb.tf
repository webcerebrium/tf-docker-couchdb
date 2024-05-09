data "docker_registry_image" "couchdb" {
  name = "${local.registry}"
}
