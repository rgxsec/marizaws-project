# AWS Threat Detection & Response Platform

A cloud-native security platform built on AWS that demonstrates real-world threat detection, AI-assisted triage, and automated remediation.

## Architecture

- **VPC** — Public/private subnets, ALB, WAF, EC2 Bastion, RDS PostgreSQL
- **Monitoring** — CloudTrail, VPC Flow Logs, WAF Logs, GuardDuty, Security Hub
- **Detection** — EventBridge rules → Lambda engine → Bedrock (Claude) AI triage
- **Response** — Step Functions remediation, DynamoDB audit trail, SNS alerts



