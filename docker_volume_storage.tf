resource "docker_volume" storage {
  name = "${local.project}-couchdb-storage-${local.postfix}"
}
