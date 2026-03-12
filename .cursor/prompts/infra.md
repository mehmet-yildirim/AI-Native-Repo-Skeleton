Scaffold deployment infrastructure for the specified platform — Terraform configs, Kubernetes manifests, CI/CD workflows, secrets management, and monitoring setup.

This prompt generates the infrastructure-as-code and pipeline files needed to deploy an application. Run it when setting up deployment for a new project or environment.

---

## Subcommands

| Subcommand | What it generates |
|---|---|
| `aws init` | Terraform (VPC, ECS/EKS, ECR, RDS, CloudFront), OIDC IAM role, GitHub Actions CD workflows |
| `gcp init` | Terraform (VPC, Cloud Run/GKE, Cloud SQL, Artifact Registry), WIF, GitHub Actions CD workflows |
| `onprem init` | Kubernetes manifests, Ansible inventory, Harbor config, self-hosted runner CD workflow |
| `<platform> ci` | Generate or update CI/CD workflow only |
| `<platform> secrets` | Scaffold secrets management (Secrets Manager / Secret Manager / Vault) |
| `<platform> database` | Scaffold database provisioning Terraform or Ansible |
| `<platform> monitoring` | Scaffold monitoring (CloudWatch / Cloud Monitoring / Prometheus+Grafana) |

---

## Step 1: Detect Context

Reference `@CLAUDE.md`, `@.project-config.yaml`, and `@Dockerfile` (if present) to identify:
- App name, container port, database type
- GitHub org/repo (for OIDC/WIF configuration)
- Target environments (staging / production)

---

## `aws init`

Generate:
```
infrastructure/
├── modules/vpc/, ecs-service/, ecr/, rds-postgres/
├── environments/staging/, environments/production/
├── iam-oidc.tf          # GitHub Actions OIDC provider + deploy IAM role
├── backend.tf           # S3 remote state + DynamoDB locking
└── providers.tf
.github/workflows/cd-staging.yml    # OIDC auth, ECR push, ECS update
.github/workflows/cd-production.yml # Tag-triggered, production environment gate
scripts/bootstrap-aws.sh            # Create state bucket, DynamoDB table, ECR repos
docs/deployment/aws-setup.md        # Setup guide + runbook
```

**ECS task definition**: inject secrets via `secrets` array with Secrets Manager ARN — never plain env vars.
**IAM role**: `AssumeRoleWithWebIdentity` scoped to `repo:org/repo:*`, minimum permissions (ECR push + ECS update).
**All resources in private subnets**; only ALB in public subnet.

---

## `gcp init`

Generate:
```
infrastructure/
├── modules/vpc/, cloud-run-service/, artifact-registry/, cloud-sql/
├── environments/staging/, environments/production/
├── wif.tf               # Workload Identity Federation + deploy service account
├── backend.tf           # GCS remote state
└── providers.tf
.github/workflows/cd-staging.yml    # WIF auth, Artifact Registry push, Cloud Run deploy
.github/workflows/cd-production.yml # Tag-triggered, production gate
scripts/bootstrap-gcp.sh            # Enable APIs, create GCS bucket, configure WIF
docs/deployment/gcp-setup.md        # Setup guide
```

**Cloud Run**: `secret_key_ref` for secrets — never plain env values. `cpu_idle = true`. Private VPC connector for Cloud SQL.
**WIF**: `principalSet://` binding scoped to specific repository — **no service account key files**.

---

## `onprem init`

Generate:
```
k8s/
├── namespaces.yaml
├── production/deployment.yaml  # topology spread, probes, preStop, resource limits
├── production/service.yaml
├── production/ingress.yaml     # cert-manager TLS annotation
├── production/hpa.yaml
├── production/networkpolicy.yaml
└── monitoring/servicemonitor.yaml
ansible/
├── inventories/production/hosts.yml  (TODO: fill in server IPs)
├── inventories/production/group_vars/all.yml
└── site.yml
.github/workflows/cd-onprem.yml     # Self-hosted runner: Harbor push, kubectl rollout
docs/deployment/onprem-setup.md     # k3s install, MetalLB, Harbor, Vault, runner setup
```

**Rolling update**: `maxUnavailable: 0`, `maxSurge: 1` — zero-downtime.
**Vault Agent Injector** annotations for secret injection if Vault is in use.

---

## `<platform> secrets`

Generate platform-specific secrets infrastructure:
- **AWS**: Secrets Manager Terraform resources + ECS task definition secrets array references
- **GCP**: Secret Manager Terraform + Cloud Run `secret_key_ref` references + IAM bindings
- **On-prem**: Vault policy HCL + Kubernetes auth role + pod annotation template

Include `docs/deployment/secrets-management.md` explaining how to populate values without committing them.

---

## `<platform> database`

- **AWS**: Aurora Serverless v2 Terraform (private subnet, auto-rotation, deletion protection in prod)
- **GCP**: Cloud SQL Terraform (private IP, PITR enabled, regional HA in prod)
- **On-prem**: Ansible role (PostgreSQL install, replication, WAL archiving)

---

## `<platform> monitoring`

- **AWS**: CloudWatch alarms + Dashboard + SNS Terraform; Logs Insights saved queries
- **GCP**: Cloud Monitoring alert policies + notification channel Terraform
- **On-prem**: kube-prometheus-stack Helm values + ServiceMonitor + AlertManager rules + Grafana dashboard JSON

---

## After Generation

Report all generated files, clearly mark TODOs (account IDs, IPs, project IDs), then provide an ordered setup checklist:
```
1. Fill TODO placeholders in terraform.tfvars / hosts.yml
2. Run scripts/bootstrap-<platform>.sh
3. Run: terraform init && terraform apply (staging first)
4. Add GitHub Actions variables from docs/deployment/*.md
5. Run: @.cursor/prompts/db.md init  — set up database migrations
6. Run: @.cursor/prompts/deploy.md staging  — verify first deployment
```

---

**Platform and subcommand** (`aws init`, `gcp ci`, `onprem secrets`, etc.):
