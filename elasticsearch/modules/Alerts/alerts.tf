resource "elasticstack_kibana_alerting_rule" "custom_threshold_rule" {
  name         = "New threshold rule"
  consumer     = "alerts"
  notify_when  = "onActionGroupChange"
  rule_type_id = "observability.rules.custom_threshold"
  interval     = "1m"
  enabled      = true
  alert_delay  = 1
  tags         = []
  params = jsonencode({
    criteria = [
      {
        comparator = ">"
        metrics = [
          {
            name    = "A"
            aggType = "count"
          }
        ]
        threshold = [100]
        timeSize  = 1
        timeUnit  = "m"
      }
    ]
    alertOnNoData          = false
    alertOnGroupDisappear  = false
    searchConfiguration = {
      query = {
        query    = ""
        language = "kuery"
      }
      index = "logs-*"
    }
  })
  actions {
    group = "custom_threshold.fired"
    id    = var.slack_alert
    params = jsonencode({
      message = "{{context.reason}}\n\n{{rule.name}} is active.\n\n[View alert details]({{context.alertDetailsUrl}})\n"
    })
  }
}
