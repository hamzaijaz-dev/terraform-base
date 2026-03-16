data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

locals {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "events:UpdateConnection",
          "events:UpdateArchive",
          "events:UpdateApiDestination",
          "events:TestEventPattern",
          "events:StartReplay",
          "events:PutTargets",
          "events:PutRule",
          "events:PutPermission",
          "events:PutPartnerEvents",
          "events:PutEvents",
          "events:List*",
          "events:InvokeApiDestination",
          "events:Describe*",
          "events:CreateConnection",
          "events:CreateArchive"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:BatchGetItem"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/app-data-table"
        ]
      },
      {
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:secretsmanager:*:*:secret:email*",
          "arn:aws:secretsmanager:*:*:secret:/email/*",
          "arn:aws:secretsmanager:*:*:secret:/shared-services/*",
          "arn:aws:secretsmanager:*:*:secret:/${var.application}/*",
          "arn:aws:secretsmanager:*:*:secret:/app/${var.application}/*",
          "arn:aws:secretsmanager:*:*:secret:/${var.service}/*",
          "arn:aws:secretsmanager:*:*:secret:/app/*",
          "arn:aws:secretsmanager:*:*:secret:/platform/*"
        ]
      },
      {
        "Action" : [
          "ssm:List*",
          "ssm:Get*",
          "ssm:Describe*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:ssm:${var.region}:${local.aws_account_id}:parameter/${var.application}/${var.service}/*",
          "arn:aws:ssm:${var.region}:${local.aws_account_id}:parameter/platform/*",
          "arn:aws:ssm:${var.region}:${local.aws_account_id}:parameter/${var.application}/*",
          "arn:aws:ssm:${var.region}:${local.aws_account_id}:parameter/${var.service}/*",
        ]
      },
      {
        "Action" : [
          "ec2:UnassignPrivateIpAddresses",
          "ec2:List*",
          "ec2:Get*",
          "ec2:DescribeNetworkInterfaces",
          "ec2:Describe*",
          "ec2:DeleteNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:AssignPrivateIpAddresses"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "lambda:*",
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${var.application}*",
          "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${var.application}-${var.service}*",
          "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${var.service}*",
        ]
      },
      {
        "Action" : [
          "s3:RestoreObject",
          "s3:PutObjectVersionTagging",
          "s3:PutObjectVersionAcl",
          "s3:PutObjectTagging",
          "s3:PutObjectRetention",
          "s3:PutObjectAcl",
          "s3:PutObject",
          "s3:List*",
          "s3:GetObjectVersion",
          "s3:GetObjectTagging",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:Get*",
          "s3:DeleteObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          module.data_bucket.s3_bucket_arn,
          "${module.data_bucket.s3_bucket_arn}/*"
        ]
      },
      {
        "Action" : [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "kms:*",
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:example-app*",
          "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:${var.service}-*-import-queue",
          "arn:aws:sqs:us-east-1:${data.aws_caller_identity.current.account_id}:${var.service}-*-import-dlq",
        ]
      }
    ]
  })
}

