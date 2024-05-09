resource "local_file" "backup" {
   content = <<EOF
#!/usr/bin/env bash
set -ex

export ENV=${var.network_params.env}
export DIR="$( cd "$( dirname "$${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export AWS_ACCESS_KEY_ID=${local.aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${local.aws_secret_access_key}
export AWS_REGION=${local.aws_region}

now() {
    date +"%Y%m%dT%H%M%S"
}

cd $(dirname "$DIR")/exchange
rm -rf *.backup.gz *.backup
docker run --rm -i \
    --name=couchdb_backup \
    --network=${local.network_id} \
    -v ${local.volume_exchange}:/docs \
    -e COUCH_URL=http://${local.host}:5984 \
    wcrbrm/couchdocs \
    bash -c "couchdocs b"

for f in *.backup.gz; do gunzip -q -f $f; done
export FN=${local.project}-couchdb-$ENV-${local.postfix}-`now`.backup.tar.gz
tar zcvf $FN *.backup

export FULL_S3_PATH=s3://${local.aws_backup_bucket}/${local.aws_backup_path}/$FN
echo "Uploading to $FULL_S3_PATH"
aws s3 cp $FN $FULL_S3_PATH 
echo "Backup Done"

EOF
   filename = "./bin/couchdb-backup.sh"
   file_permission = "0777"
}



