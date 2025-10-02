variable "spaces" {
  description = "Kibana spaces to create"
  type = map(object({
    space_id = string
    name     = string
    initials = string
  }))
  default = {}
}