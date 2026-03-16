# terraform-base

## Overview

This repository is a **Terraform knowledge base** that contains reusable building blocks.

Currently it provisions:

- **An S3 bucket** for application data
- **A DynamoDB table** for storing records
- **IAM role and policy** for a Lambda function
- **SSM parameters and outputs** to wire these resources into your applications

## Module: `resources`

### Inputs

The module is parameterized with the following variables (see `variables.tf`):

- **`region`**: AWS region (default: `us-east-1`)
- **`lambda_role_name_prefix`**: Optional prefix for Lambda role naming
- **`lambda_role_path`**: IAM path for the Lambda role
- **`application`**: Logical application name (generic, e.g. `app1`)
- **`service`**: Logical service name (generic, e.g. `service-a`)
- **`eventbridge_bus_name`**: Name of the EventBridge bus
- **`aws_env`**: Environment identifier (e.g. `dev`, `staging`, `prod`)
- **`deletion_protection_enabled`**: Controls table deletion protection (default: `true`)
- **`point_in_time_recovery`**: Enables DynamoDB PITR (default: `true`)

### What it creates

- **S3 bucket**
  - Name pattern: `\${var.application}-\${var.service}-data-files-\${var.aws_env}`
  - Created via the official `terraform-aws-modules/terraform-aws-s3-bucket` module

- **DynamoDB table**
  - Name: `app-data-table`
  - Hash key: `tax_id`
  - Range key: `date`
  - Additional attribute: `name`
  - Global secondary index on `name` + `date`

- **IAM role and policy for Lambda**
  - Trusts `lambda.amazonaws.com` and `events.amazonaws.com`
  - Allows access to:
    - The `app-data-table` DynamoDB table
    - The data S3 bucket
    - CloudWatch Logs
    - SSM parameters under your generic application/service paths
    - Selected Secrets Manager secrets under generic paths
    - Common EC2 networking actions used by Lambda
    - Example SQS queues using generic naming (no real product names)

- **SSM parameters**
  - Stores:
    - Lambda role ARN
    - Data bucket name
    - Data table name
  - Uses generic parameter names like:
    - `/${var.application}/${var.service}/lambda_role`
    - `/${var.application}/data_bucket`
    - `/${var.application}/data_table`

### Outputs

From `output.tf`:

- **`parameter_names`**: Map of created SSM parameter names
- **`parameter_values`**: Sensitive map of parameter values
- **`data_bucket_name`**: Name of the S3 data bucket
- **`data_bucket_arn`**: ARN of the S3 data bucket
