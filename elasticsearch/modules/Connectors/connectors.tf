resource "elasticstack_kibana_action_connector" "slack" {
  for_each          = var.slack
  name              = each.value.name
  space_id          = each.value.space_id
  connector_type_id = ".slack"
  secrets = jsonencode({
    webhookUrl = each.value.webhookUrl
  })
}

resource "elasticstack_kibana_action_connector" "jira" {
  for_each          = var.jira
  name              = each.value.name
  connector_type_id = ".jira"
  space_id = each.value.space_id
  config = jsonencode({
    apiUrl = ""
    projectKey = each.value.projectKey
  })
  secrets = jsonencode({
    apiToken = ""
    email = ""
  })
}

resource "elasticstack_kibana_action_connector" "server_log" {
  for_each = var.server_log
  name              = each.value.name
  connector_type_id = ".server-log"
  space_id          = each.value.space_id
}
