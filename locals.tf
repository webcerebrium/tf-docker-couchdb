locals {
    registry = "registry.indygateway.net/pos-couchdb"
    
    network_id = var.network_params.network_id
    project = var.network_params.project
    postfix = var.network_params.postfix

    volume_exchange = var.exchange_params.volume_exchange
    aws_profile = var.exchange_params.aws_profile
    aws_region = var.exchange_params.aws_region
    aws_access_key_id = var.exchange_params.aws_access_key_id
    aws_secret_access_key = var.exchange_params.aws_secret_access_key
    aws_backup_bucket = var.exchange_params.aws_backup_bucket
    aws_backup_path = var.exchange_params.buckets.couchdb

    host = "couchdb-${var.network_params.postfix}"
    healthcheck_url = var.healthcheck_url

    ports = var.network_params.workspace == "local" ? [{
        internal = 5984
        external = 5984
    }]: []
}