resource "docker_image" "couchdb" {
  name          = data.docker_registry_image.couchdb.name
  pull_triggers = [ data.docker_registry_image.couchdb.sha256_digest ]
  keep_locally = true
}