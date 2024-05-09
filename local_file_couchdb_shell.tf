resource "local_file" "couchdb_shell" {
   content = <<EOF
#!/usr/bin/env bash

echo Please use COUCHDB_URL as a reference to database root
set -e
docker run --rm -it \
    --network=${local.network_id} \
    -v ${local.volume_exchange}:/exchange \
    -w /exchange \
    -e COUCHDB_URL=http://${local.host}:5984 \
    -e PS1='(\[\033[30;47m\]couchdb:\w\$\[\033[0m\]) ' \
    wcrbrm/curljq bash

EOF
   filename = "./bin/couchdb-shell.sh"
   file_permission = "0777"
}



