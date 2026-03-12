# GCP Deployment Standards

## Default Architecture
- **Container workloads**: Cloud Run (stateless HTTP, auto-scale to 0)
- **Kubernetes**: GKE Autopilot (when Kubernetes features needed)
- **Database**: Cloud SQL PostgreSQL (private IP, no public IP)
- **Registry**: Artifact Registry (replaces Container Registry)
- **Secrets**: Secret Manager (injected into Cloud Run as env, not plain vars)
- **IaC**: Terraform with GCS remote state
- **Load balancing**: Cloud Load Balancing + Cloud Armor (WAF)

## Choose Cloud Run vs GKE
- **Cloud Run**: stateless HTTP, auto-scale to 0 useful, simplicity preferred, single team
- **GKE Autopilot**: StatefulSets needed, custom scheduling, GPU, multi-team platform

## GitHub Actions Authentication (Workload Identity Federation — no service account keys)
- Create Workload Identity Pool + Provider for `token.actions.githubusercontent.com`
- Map `assertion.repository` to restrict to specific repo
- Bind GitHub service account to WIF pool with `roles/iam.workloadIdentityUser`
- Use `google-github-actions/auth@v2` with `workload_identity_provider` and `service_account`
- **Never** create or store service account keys (JSON files)
- Minimum permissions: `roles/run.developer` + `roles/artifactregistry.writer`

## Cloud Run
- `min_instance_count = 1` for production (avoid cold starts); `0` for staging
- Secrets injected via `secret_key_ref` — **not** plain environment variable values
- `cpu_idle = true` — throttle CPU between requests (significant cost savings)
- `private_network_only` egress via VPC connector for Cloud SQL access
- Liveness probe: `GET /health/live`; Startup probe: `GET /health/ready`

## Networking
- Private VPC with `private_ip_google_access = true` on subnets
- Cloud SQL: `ipv4_enabled = false` — private IP only, accessible via Private Service Connect
- VPC connector for Cloud Run → Cloud SQL private connectivity

## Artifact Registry
- Use `DOCKER` format; region-specific: `{region}-docker.pkg.dev/{project}/{repo}`
- Cleanup policy: keep last 10 images
- `gcloud auth configure-docker {region}-docker.pkg.dev` in CI before docker push

## Secret Manager
- One secret per value: `{app}-{environment}-{name}`
- `auto {}` replication — automatically replicated across regions
- Grant `roles/secretmanager.secretAccessor` to the Cloud Run service account only
- Access via Cloud Run `value_source.secret_key_ref`, not plain env vars

## Cloud SQL
- `availability_type = "REGIONAL"` for production (HA with automatic failover)
- `ipv4_enabled = false` — private IP only
- `deletion_protection = true` for production
- Enable point-in-time recovery; 30-day backup retention for production

## Cloud Armor (WAF)
- Attach to load balancer backend in production
- Enable OWASP Top 10 preconfigured rules: `sqli-v33-stable`, `xss-v33-stable`
- Enable adaptive protection for DDoS mitigation

## GKE Autopilot
- Workload Identity Federation: annotate pods with `iam.gke.io/gcp-service-account`
- `enable_private_nodes = true`; API server reachable via VPN/IAP
- No node management — GCP manages nodes, patching, and scaling

## Security Rules
- Separate GCP projects per environment (not just namespaces)
- No service account keys — use Workload Identity Federation everywhere
- Organization policy: disable public GCS buckets (`constraints/storage.uniformBucketLevelAccess`)
- Binary Authorization in production — only signed images from Artifact Registry
- VPC Service Controls for production project
- Cloud Audit Logs: data access logging enabled for Cloud SQL, Secret Manager
