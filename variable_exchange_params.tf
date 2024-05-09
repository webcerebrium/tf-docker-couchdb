variable "exchange_params" {
    type = object({
        volume_exchange = string
        aws_profile = string
        aws_region = string
        aws_access_key_id = string
        aws_secret_access_key = string
        aws_backup_bucket = string
        buckets = map(string)
    })
}
