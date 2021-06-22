variable "Instance" {
  type = map(string)
  default = {
    "micro" = "t2.micro"
    "small" = "t2.small"
    "medium" = "t2.medium"
    "large" = "t2.large"
    "DBMicro" = "db.t2.micro"
  }
}

variable "subnet_id" {}
variable "security_id" {}