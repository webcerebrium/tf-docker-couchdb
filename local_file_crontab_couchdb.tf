resource "local_file" "crontab_couchdb" {
   content = <<EOF
0 3 * * * root ${abspath(path.cwd)}/bin/couchdb-backup.sh > /var/log/couchdb-backup.log 2>&1
EOF

   filename = "./cron.d/crontab_couchdb"
}
