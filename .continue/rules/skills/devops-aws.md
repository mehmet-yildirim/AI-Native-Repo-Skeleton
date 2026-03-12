# AWS Deployment Standards

## Default Architecture
- **Container workloads**: ECS Fargate + ALB + ECR
- **Kubernetes**: EKS (when multi-team, advanced scheduling, or GitOps required)
- **Serverless**: Lambda (async/event-driven, < 15 min runtime)
- **Database**: RDS Aurora Serverless v2 (PostgreSQL) in private subnets
- **Frontend**: S3 + CloudFront
- **Secrets**: AWS Secrets Manager (sensitive) / SSM Parameter Store (config)
- **IaC**: Terraform with S3 remote state + DynamoDB locking

## IAM & GitHub Actions (OIDC — no stored credentials)
- Create OIDC provider for `token.actions.githubusercontent.com`
- Create IAM role with `AssumeRoleWithWebIdentity` for specific `repo:org/repo:*`
- Use `aws-actions/configure-aws-credentials@v4` with `role-to-assume` in workflows
- **Never** store `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` in GitHub Secrets
- Least-privilege role: only ECR push + ECS update permissions

## Networking
- Private subnets for all application and database resources
- Public subnets for ALB only
- `single_nat_gateway = true` for staging (cost), `false` for production (HA)
- Security groups: ALB SG → app SG → RDS SG (each only allows its upstream)
- No EC2 key pairs — use Systems Manager Session Manager for shell access

## ECS Fargate
- `FARGATE` launch type, `awsvpc` network mode
- Secrets injected via `secrets` array with Secrets Manager ARN — never plain env vars
- `deployment_circuit_breaker { rollback = true }` — auto-rollback on deployment failure
- CloudWatch Logs: `/ecs/{app}/{environment}` log group
- `lifecycle { ignore_changes = [task_definition] }` in Terraform — CI/CD manages image updates

## ECR
- `image_tag_mutability = "IMMUTABLE"` — prevent tag overwriting
- `scan_on_push = true` — vulnerability scan every push; fail CI on CRITICAL CVEs
- Lifecycle policy: keep last 10 images

## Secrets Manager
- Secret ARN referenced in ECS task definition `secrets` array
- Enable automatic rotation for database credentials
- Never inject sensitive values as plain environment variables

## RDS Aurora Serverless v2
- `ipv4_enabled = false` — private IP only
- `manage_master_user_password = true` — automatic Secrets Manager rotation
- `deletion_protection = var.environment == "production"`
- `point_in_time_recovery_enabled` for production; daily backups retained 35 days

## CloudWatch Monitoring
- ALB 5xx rate alarm → SNS → PagerDuty/Slack
- ECS CPU/memory utilization alarms
- RDS connections exhaustion alarm
- Structured JSON logs → CloudWatch Logs Insights queries

## Cost Controls
- Fargate Spot for staging and batch jobs (70% savings)
- Aurora Serverless v2 scales to 0 for non-production
- S3 Intelligent-Tiering for infrequently accessed objects
- Cost Anomaly Detection with daily budget alerts

## Security Rules
- All resources in private subnets; only ALB in public
- CloudTrail enabled in all regions; logs to S3 with integrity validation
- AWS Config for compliance drift detection
- WAF attached to CloudFront and ALB in production
- Database encryption at rest + force SSL
