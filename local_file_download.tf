resource "local_file" "download" {
  content         = <<EOF
#!/usr/bin/env bash
set -exu

export DIR="$( cd "$( dirname "$${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/couchdb-wait.sh

export DIR_EXCHANGE=$(dirname "$DIR")/exchange
export AWS_ACCESS_KEY_ID=${local.aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${local.aws_secret_access_key}
export AWS_REGION=${local.aws_region}

export PID=$(docker ps --filter "label=host=${local.host}" --format "{{.ID}}")
if [[ "$PID" != "" ]]; then
    export LAST_SQL_GZ=$(aws s3 ls s3://${local.aws_backup_bucket}/${local.aws_backup_path}/ | \
        sort | tail -n1 | rev | cut -d' ' -f1 | rev | tr -d \'[:space:]\')
    if [[ "$LAST_SQL_GZ" == "" ]]; then
        echo "ERROR: no backups found at s3://${local.aws_backup_bucket}/${local.aws_backup_path}/"
        exit 1
    fi
    export LAST_SQL=$(echo $LAST_SQL_GZ | sed -r 's/\.gz$//')

    export FULL_S3_PATH=s3://${local.aws_backup_bucket}/${local.aws_backup_path}/$LAST_SQL_GZ
    echo "Latest backup is available at $FULL_S3_PATH"
    cd $DIR_EXCHANGE
    find $DIR_EXCHANGE/ -name '*.backup' -type f -delete

    if [ -f "$DIR_EXCHANGE/$LAST_SQL" ]; then
        echo "Already downloaded to $DIR_EXCHANGE/$LAST_SQL"
    elif [ -f "$DIR_EXCHANGE/$LAST_SQL_GZ" ]; then
        echo "Already downloaded to $DIR_EXCHANGE/$LAST_SQL_GZ"
        tar zxvf $LAST_SQL_GZ
    else
        echo "Downloading $FULL_S3_PATH"
        aws s3 cp $FULL_S3_PATH $DIR_EXCHANGE/$LAST_SQL_GZ
        echo "Unpacking databases"
        tar zxvf $LAST_SQL_GZ
    fi
    
    # removing extra backups
    if [[ "${var.merchants}" != "" ]]; then
        ls -1 $DIR_EXCHANGE | grep .backup | grep -v ${var.merchants} | grep -v posconfig | grep -v posstat | xargs rm -f
        ls -All $DIR_EXCHANGE/*.backup
    fi

    for filename in $DIR_EXCHANGE/*.backup; do
        DB=$(echo "$filename" | rev | cut -f2 -d'.' | cut -f1 -d'/' | rev)
        docker run --rm -i \
            --name restore-$DB \
            --network=${local.network_id} \
            -v ${local.volume_exchange}:/docs \
            -e COUCH_URL=http://${local.host}:5984 \
            wcrbrm/couchdocs \
            bash -c "
            (curl -s -H'Content-Type: application/json' -X DELETE http://${local.host}:5984/$DB || true) &&
            (curl -s -H'Content-Type: application/json' -X PUT http://${local.host}:5984/$DB) &&
            (cat $DB.backup | couchrestore --db $DB)
            "
        rm -f $filename
    done;

    echo "CouchDB dump restored successfully. Waiting for healthcheck now"

    if [ "${local.healthcheck_url}" != "" ]; then
        echo "Waiting for Health... May take few min. ($COUNTER)"
        
        export COUNTER=60
        export DELAY=10
        HTTP_STATUS=0
        while [[ $HTTP_STATUS != 200 ]]; do
            COUNTER=$((COUNTER - 1))
            if [ "$COUNTER" == "0" ]; then
                echo "ERROR: health waiting timeout. Health check was not ready."; 
                exit 1;
            fi
            HTTP_STATUS=$(docker run \
                --rm --network=${local.network_id} \
                wcrbrm/curljq \
                curl -s -o /dev/null -w \"%\{http_code}\" \
                    "http://${local.host}:5984/${local.healthcheck_url}" | xargs)
            sleep "$DELAY"
            echo "Waiting for Health... May take few min. ($COUNTER)"
        done
    fi
else 
   echo "ERROR: couchdb docker process was not found"
   exit 1
fi
EOF
  filename        = "./bin/couchdb-download.sh"
  file_permission = "0777"
}


