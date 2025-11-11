resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/app/logs"
  retention_in_days = 30
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "AppMonitoringDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        properties = {
          metrics = [["AWS/EC2", "CPUUtilization"]],
          title   = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
