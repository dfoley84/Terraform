resource "aws_iam_role" "prometheus" {
  name   = "ecs-prometheus"
  assume_role_policy = file("${path.module}/roles/assumerole.json")
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.prometheus.name
  for_each = toset([
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonPrometheusFullAccess",
        "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
        "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess",
        "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"])
  policy_arn = each.value
  depends_on = [aws_iam_role.prometheus]
}