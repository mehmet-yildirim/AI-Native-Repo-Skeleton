# Deployment Platform Guide

This document helps teams choose a deployment target and provides the setup path for each platform.
Use the `/infra` command to scaffold the actual infrastructure files.

---

## Platform Selection

```
Do you control the servers?
│
├── NO (cloud provider manages infrastructure)
│       │
│       ├── Need Google ecosystem (BigQuery, Vertex AI, Pub/Sub)?
│       │   └── → Google Cloud Platform (GCP)
│       │
│       └── Already invested in AWS, or need broadest service range?
│           └── → Amazon Web Services (AWS)
│
└── YES (you manage the hardware or VMs)
        └── → On-Premise
```

### Quick comparison

| Factor | AWS | GCP | On-Premise |
|---|---|---|---|
| Container workload | ECS Fargate | Cloud Run | k3s / kubeadm |
| Kubernetes | EKS | GKE Autopilot | k3s / kubeadm |
| Managed DB | Aurora Serverless v2 | Cloud SQL | Self-managed PostgreSQL |
| Secrets | Secrets Manager | Secret Manager | HashiCorp Vault |
| Registry | ECR | Artifact Registry | Harbor |
| CI auth | OIDC → IAM role | Workload Identity Federation | Self-hosted runner |
| IaC | Terraform or CDK | Terraform | Terraform + Ansible |
| Cost model | Pay-per-use | Pay-per-use + scale-to-zero | CapEx (hardware) |
| Compliance | FedRAMP, HIPAA, PCI available | FedRAMP, HIPAA, PCI available | Full control |

---

## AWS Setup Path

### Prerequisites
- AWS CLI installed and configured with an IAM user that has admin access (for initial setup only)
- Terraform >= 1.6 installed
- Docker installed

### Step-by-step

**1. Scaffold infrastructure**
```
/infra aws init
```
This generates: Terraform modules (VPC, ECS, ECR, RDS), GitHub Actions workflows, and a setup guide.

**2. Bootstrap the AWS account** (one-time)
```bash
bash scripts/bootstrap-aws.sh
# Creates: S3 state bucket, DynamoDB lock table, ECR repositories
```

**3. Configure Terraform variables**
Fill in `infrastructure/environments/staging/terraform.tfvars`:
```hcl
aws_account_id = "123456789012"
aws_region     = "eu-west-1"
app_name       = "myapp"
github_org     = "mycompany"
github_repo    = "myapp"
```

**4. Deploy staging infrastructure**
```bash
cd infrastructure/environments/staging
terraform init
terraform plan   # Review before applying
terraform apply
```

**5. Configure GitHub Actions variables** (repository → Settings → Variables)
```
AWS_DEPLOY_ROLE_ARN  = arn:aws:iam::123456789012:role/github-actions-deploy-staging
ECR_REGISTRY         = 123456789012.dkr.ecr.eu-west-1.amazonaws.com
ECR_REPOSITORY       = myapp-staging
ECS_CLUSTER          = myapp-staging
ECS_SERVICE          = myapp-staging
AWS_REGION           = eu-west-1
```

**6. Populate secrets** (never in git — use AWS Console or CLI)
```bash
aws secretsmanager create-secret \
  --name /myapp/staging/database-url \
  --secret-string "postgresql://user:pass@host/dbname"
```

**7. Set up database migrations**
```
/db init
```

**8. Trigger first deployment**
```bash
git push origin main   # Triggers cd-staging.yml
```

---

## GCP Setup Path

### Prerequisites
- `gcloud` CLI installed and authenticated
- Terraform >= 1.6 installed
- Docker installed

### Step-by-step

**1. Scaffold infrastructure**
```
/infra gcp init
```

**2. Bootstrap the GCP project** (one-time)
```bash
bash scripts/bootstrap-gcp.sh
# Enables APIs, creates GCS state bucket, configures Workload Identity Federation
```

**3. Configure Terraform variables**
Fill in `infrastructure/environments/staging/terraform.tfvars`:
```hcl
project_id    = "myapp-staging-123456"
region        = "europe-west1"
app_name      = "myapp"
github_org    = "mycompany"
github_repo   = "myapp"
```

**4. Deploy staging infrastructure**
```bash
cd infrastructure/environments/staging
terraform init -backend-config="bucket=myapp-terraform-state"
terraform plan
terraform apply
```

**5. Configure GitHub Actions variables**
```
GCP_WORKLOAD_IDENTITY_PROVIDER = projects/123456/locations/global/workloadIdentityPools/github-pool/providers/github-provider
GCP_SERVICE_ACCOUNT            = github-deploy-staging@myapp-staging.iam.gserviceaccount.com
GCP_REGION                     = europe-west1
GCP_PROJECT                    = myapp-staging-123456
APP_NAME                       = myapp
CLOUD_RUN_SERVICE              = myapp-staging
```

**6. Populate secrets** (GCP Console or `gcloud`)
```bash
echo -n "postgresql://user:pass@host/dbname" | \
  gcloud secrets versions add myapp-staging-database-url --data-file=-
```

**7. Set up database migrations**
```
/db init
```

**8. Trigger first deployment**
```bash
git push origin main   # Triggers cd-staging.yml
```

---

## On-Premise Setup Path

### Prerequisites
- 3+ servers (bare metal or VMs) for Kubernetes HA
- Network admin access (to configure reserved IPs for MetalLB)
- Ansible installed on your workstation

### Step-by-step

**1. Scaffold infrastructure**
```
/infra onprem init
```

**2. Fill in server IPs**
Edit `ansible/inventories/production/hosts.yml`:
```yaml
k3s_server:
  hosts:
    node1: { ansible_host: 192.168.1.10 }
    node2: { ansible_host: 192.168.1.11 }
    node3: { ansible_host: 192.168.1.12 }
k3s_agent:
  hosts:
    worker1: { ansible_host: 192.168.1.20 }
```

**3. Configure the MetalLB IP pool**
Edit `k8s/metallb-config.yaml` with your reserved IP range:
```yaml
addresses: ["192.168.1.200-192.168.1.210"]
```

**4. Provision servers with Ansible**
```bash
ansible-playbook -i ansible/inventories/production ansible/site.yml
```

**5. Install Kubernetes tools**
```bash
# Install k3s (first server node)
curl -sfL https://get.k3s.io | sh -s - server --cluster-init --token "${K3S_TOKEN}"

# Install MetalLB, Nginx Ingress, cert-manager, Vault
bash scripts/install-cluster-tools.sh
```

**6. Set up Harbor (private registry)**
```bash
helm upgrade --install harbor harbor \
  --repo https://helm.goharbor.io \
  --namespace registry --create-namespace \
  --values helm/harbor-values.yaml
```

**7. Initialize Vault**
```bash
vault operator init                  # Save unseal keys and root token securely
vault operator unseal <key1>
vault operator unseal <key2>
vault operator unseal <key3>
vault secrets enable -path=secret kv-v2
vault auth enable kubernetes
```

**8. Install GitHub Actions self-hosted runner**
```bash
# On a dedicated server inside the network
# Download and configure runner from: https://github.com/org/repo/settings/actions/runners
./config.sh --url https://github.com/myorg/myapp --token "${RUNNER_TOKEN}"
sudo ./svc.sh install && sudo ./svc.sh start
```

**9. Deploy to Kubernetes**
```bash
kubectl apply -k k8s/production/
kubectl rollout status deployment/myapp -n production
```

---

## CI/CD Workflow Overview (All Platforms)

```
Developer pushes PR
    │
    ├─ ci.yml → lint + typecheck + tests + security scan + build
    │              (same for all platforms — platform-agnostic)
    │
Merge to main
    │
    ├─ cd-staging.yml → build image → push to registry → deploy to staging
    │   AWS:     ECR push + ECS update service
    │   GCP:     Artifact Registry push + Cloud Run deploy
    │   On-prem: Harbor push + kubectl rollout
    │
    └─ Smoke tests pass → staging is live
    │
Tag v*.*.* pushed
    │
    ├─ cd-production.yml → (same deploy steps) → environment approval gate
    │   Production environment requires manual approval in GitHub
    │
    └─ Post-deploy: /deploy monitoring plan
```

---

## Environment Variables Reference

All platforms share the same application-level variable names. Only the values differ.

| Variable | Description | Where stored |
|---|---|---|
| `DATABASE_URL` | Full DB connection string | AWS: Secrets Manager / GCP: Secret Manager / On-prem: Vault |
| `JWT_SECRET` | JWT signing secret | Same as above |
| `REDIS_URL` | Redis/Memcached connection | Same as above |
| `NODE_ENV` / `APP_ENV` | Environment name | Plain env var (not sensitive) |
| `PORT` | Container listening port | Plain env var |
| `LOG_LEVEL` | Logging verbosity | AWS: SSM Parameter Store / GCP: Cloud Run env / On-prem: ConfigMap |

---

## Runbook: Common Operations

### View live logs
```bash
# AWS
aws logs tail /ecs/myapp/production --follow

# GCP
gcloud run services logs read myapp --project=myapp-prod --region=europe-west1 --tail=50

# On-premise
kubectl logs -f -l app=myapp -n production
```

### Scale the service
```bash
# AWS
aws ecs update-service --cluster myapp-production --service myapp --desired-count 5

# GCP (Cloud Run auto-scales — set max instances)
gcloud run services update myapp --max-instances=20 --region=europe-west1

# On-premise
kubectl scale deployment myapp --replicas=5 -n production
```

### Emergency rollback
```bash
# AWS — roll back to previous task definition
aws ecs update-service \
  --cluster myapp-production \
  --service myapp \
  --task-definition myapp:PREVIOUS_REVISION

# GCP — roll back to previous Cloud Run revision
gcloud run services update-traffic myapp \
  --to-revisions=PREV_REVISION=100 \
  --region=europe-west1

# On-premise
kubectl rollout undo deployment/myapp -n production
```
