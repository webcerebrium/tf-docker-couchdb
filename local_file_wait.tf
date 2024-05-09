resource "local_file" "wait" {
   content = <<EOF
#!/usr/bin/env bash
set -eux
export PID=$(docker ps --filter "label=host=${local.host}" --format "{{.ID}}")
   
out() { echo [`date`] $@; }
die() { echo [`date`] FATAL $@; exit 1; }

react_on_status() {
  local RESPONSE=$(docker exec $PID /root/all-dbs.sh)
  if [[ "$RESPONSE" == *"_users"* ]]; then
    echo "READY"
    exit 0
  fi
  if [[ "$RESPONSE" == "[]" ]]; then
    # ready for init script
    docker exec -it "$PID" /root/init.sh
    echo "INITIALIZED"
    exit 0
  fi
}

if [[ "$PID" != "" ]]; then
    export COUNTER=30
    export DELAY=10
    export SERVICE="COUCHDB"

    out "Waiting for $SERVICE... May take 1 min. ($COUNTER)"
    until [[ "$(react_on_status)" != "" ]]
    do
        COUNTER=$((COUNTER - 1))
        if [ "$COUNTER" == "0" ]; then
            die "$HOST waiting timeout. $SERVICE was not ready."
        fi
        sleep "$DELAY"
        out "Waiting for $SERVICE... May take 1 min. ($COUNTER)"
    done
    out "ALIVE"
else 
   out "ERROR: couchdb docker process was not found"
   exit 1
fi
EOF

   filename = "./bin/couchdb-wait.sh"
   file_permission = "0777"
}
