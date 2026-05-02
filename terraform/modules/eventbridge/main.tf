## EventBridge

resource "aws_cloudwatch_event_bus" "security_event_bus" {
    name = "security-event-bus-marizaws"
  
}


resource "aws_cloudwatch_event_rule" "eb_rule1" {
  name = "guard-duty-findings-severity"
  description = "It triggers event to Lambda upon observing AWS GuardDuty findings above 7 severity"

  event_pattern = jsonencode({
    
  })
}