resource "local_file" "bulk_docs" {
   content = <<EOF
#!/usr/bin/env bash
set -ex
docker run --rm -i \
  --network=${local.network_id} \
  wcrbrm/curljq curl -X POST \
  -H"Content-Type: application/json" \
  http://${local.host}:5984/rabers/_bulk_docs -d @-

EOF
   filename = "./bin/couchdb-bulk-docs.sh"
   file_permission = "0777"
}



