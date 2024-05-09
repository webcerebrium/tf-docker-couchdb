resource "local_file" "couchdb_tasks" {
   content = <<EOF
#!/usr/bin/env bash

set -e
# this endpoint shows the status of couchdb indexes creation
docker run --rm -it \
    --network=${local.network_id} \
    wcrbrm/curljq curl -s http://${local.host}:5984/_active_tasks/ | jq .

EOF
   filename = "./bin/couchdb-tasks.sh"
   file_permission = "0777"
}



