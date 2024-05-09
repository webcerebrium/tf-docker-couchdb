output "credentials" {
  value = ({
    url = "http://${local.host}:5984/",
    host = local.host,
    port = "5984",
  })
}
