variable "env"{
  description
}
variable "container_name" {
  description = "Container Name"
  default     = "Wordpress"
}

variable "image" {
  description = "Container Image"
  default     = "wordpress:latest"
}

variable "int_port" {
  description = "internal port for container"
  default     = "2368"
}

variable "ext_port" {
  description = "external port for container"
  default     = "80"
}
