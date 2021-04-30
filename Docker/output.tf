output "IP Address" {
  value = "${module.container.ip}"
}

output "Container Name" {
  value = "${module.container.container_name}"
}
