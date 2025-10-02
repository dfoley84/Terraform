variable "workspace" {}
variable "slack" {
  type = map(object({
    name = string
    webhookUrl = string
    space_id = string
  }))
  default = {}
}
variable "jira" {
  type = map(object({
    name = string
    projectKey = string
    space_id = string
  }))
  default = {}
}
variable "server_log" {
  type = map(object({
    name = string
    space_id = string
  }))
  default = {}
}
