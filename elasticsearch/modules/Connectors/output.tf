output "slack_connector_ids" {
  description = "Map of Slack names to their IDs"
  value = {
    for key, connector in elasticstack_kibana_action_connector.slack : key => connector.id
  }
}

output "jira_connector_ids" {
  description = "Map of Jira names to their IDs"
  value = {
    for key, connector in elasticstack_kibana_action_connector.jira : key => connector.id
  }
}

output "server_log_connector_ids" {
  description = "Map of Server Log names to their IDs"
  value = {
    for key, connector in elasticstack_kibana_action_connector.server_log : key => connector.id
  }
}