data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
## Adding s3 bucket

resource "aws_s3_bucket" "marizaws_bucket" {
  bucket = "marizaws-bucket"

}

resource "aws_s3_bucket_policy" "marizaws_bucket" {
  bucket = aws_s3_bucket.marizaws_bucket.id

  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Sid       = "AWSCloudTrailAclCheck20150319"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "s3:GetBucketAcl"
      Resource  = "arn:aws:s3:::marizaws-bucket"
      Condition = {
        StringEquals = {
          "aws:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:trail/marizaws_trail"
        }
      }
    },
    {
      Sid       = "AWSCloudTrailWrite20150319"
      Effect    = "Allow"
      Principal = { Service = "cloudtrail.amazonaws.com" }
      Action    = "s3:PutObject"
      Resource  = "arn:aws:s3:::marizaws-bucket/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl"  = "bucket-owner-full-control"
          "aws:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:trail/marizaws_trail"
        }
      }
    }
  ]
})
}


### AWS CloudTrail


resource "aws_cloudtrail" "cloudtrail_marizaws" {
  name = "marizaws-cloudtrail"
  depends_on = [aws_s3_bucket_policy.marizaws_bucket]   
  include_global_service_events = true

  s3_bucket_name = aws_s3_bucket.marizaws_bucket.id

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudwatch_log_group_cloudtrail.arn}:*"
  cloud_watch_logs_role_arn = aws_iam_role.cloud_trail_role.arn


}


resource "aws_cloudwatch_log_group" "cloudwatch_log_group_cloudtrail" {
  name = "marizaws-cloudwatch-log-group"

  tags = {
    Environment = "production"
    Application = "CloudTrail"
  }

}

resource "aws_iam_role" "cloud_trail_role" {
  name = "cloud-trail-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "cloud_trail_role_policy" {
  name = "cloudtrail-cloudwatch-policy"
  role = aws_iam_role.cloud_trail_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "AWSCloudTrailCreateLogStream2014110",
            Effect = "Allow",
            Action = [
                "logs:CreateLogStream"
            ],
            Resource = [
                "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudwatch_log_group_cloudtrail.name}:log-stream:*"
            ]
        },
        {
            Sid = "AWSCloudTrailPutLogEvents20141101",
            Effect = "Allow",
            Action = [
                "logs:PutLogEvents"
            ],
            Resource = [
                "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudwatch_log_group_cloudtrail.name}:log-stream:*"
                    ]
        }
    ]
})
}



## VPC Flow Logs


resource "aws_flow_log" "flow_log" {
  vpc_id = var.vpc_id
  iam_role_arn = aws_iam_role.vpcflowlogs_role.arn
  log_destination = aws_cloudwatch_log_group.cloudwatch_log_group_flowlog.arn
  traffic_type = "ALL"

}


resource "aws_cloudwatch_log_group" "cloudwatch_log_group_flowlog" {
  name = "marizaws-cloudwatch-log-group-vpcflowlogs"

  tags = {
    Environment = "production"
    Application = "VPC Flow Logs"
  }

}


resource "aws_iam_role" "vpcflowlogs_role" {
  name = "vpc-flowlogs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "vpcflowlogs_policy" {
  name = "marizaws-vpcflowlogs_policy"
  role = aws_iam_role.vpcflowlogs_role.id

  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}


data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}


## AWS GuardDuty


resource "aws_guardduty_detector" "guard_duty" {
  enable = true
}


## Security Hub


resource "aws_securityhub_account" "security_hub_account_marizaws" {
  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "aws_foundation_sbp1" {
  depends_on = [aws_securityhub_account.security_hub_account_marizaws]
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.id}::standards/aws-foundational-security-best-practices/v/1.0.0"
}