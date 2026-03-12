# On-Premise Deployment Standards

## Platform Selection
| Option | When to use |
|---|---|
| **k3s** | Small/medium clusters, edge, new on-prem Kubernetes |
| **kubeadm** | Large clusters, existing Kubernetes expertise |
| **Docker Swarm** | Simple apps, small teams, minimal K8s overhead |
| **Ansible + systemd** | Non-containerized apps, legacy workloads |

## Kubernetes (k3s recommended)
- Install with `--disable traefik` and `--disable servicelb` (use Nginx ingress + MetalLB)
- HA: 3 or 5 server nodes; worker nodes join separately
- Namespaces: `production`, `staging`, `monitoring`, `ingress`, `cert-manager`, `vault`

## Ingress (MetalLB + Nginx)
- MetalLB: assign real IPs to `LoadBalancer` services from a reserved IP pool
- Nginx Ingress Controller: single entry point for all HTTP/S traffic
- All ingress has `nginx.ingress.kubernetes.io/ssl-redirect: "true"`

## TLS (cert-manager)
- Internet-accessible: Let's Encrypt with HTTP-01 challenge via Nginx
- Air-gapped / internal: `ClusterIssuer` with internal CA (`ca.secretName`)
- Annotate ingress: `cert-manager.io/cluster-issuer: "letsencrypt-prod"`

## Secrets (HashiCorp Vault)
- Deploy Vault HA (3 replicas) via Helm chart with Vault Agent Injector
- Kubernetes auth method: pods authenticate via their service account token
- Annotate pods with `vault.hashicorp.com/agent-inject: "true"` for automatic secret injection
- **Never** store sensitive values in Kubernetes Secrets (base64 is not encryption)

## Pod Standards
- `topologySpreadConstraints`: spread replicas across nodes for HA
- `lifecycle.preStop: sleep 15` + `terminationGracePeriodSeconds: 60` for graceful drain
- `maxUnavailable: 0` in rolling update strategy — zero-downtime deploys
- Resources: always set both `requests` and `limits`

## Private Registry (Harbor)
- Self-hosted Harbor with Trivy for vulnerability scanning
- All images: `registry.mycompany.internal/{project}/{app}:{tag}`
- Configure nodes: add registry to Docker daemon trusted registries
- Block deployment if CRITICAL CVEs found

## CI/CD (GitHub Actions self-hosted runner)
- Runner on dedicated server inside the network — outbound only to api.github.com
- No cloud credentials needed; the runner already has `kubectl` access
- Install as systemd service for automatic restart

## Automation (Ansible)
- Structure: `inventories/{env}/hosts.yml` + `roles/{component}/tasks/main.yml`
- `roles/common`: OS hardening, NTP, UFW firewall, unattended security updates
- `roles/postgresql`: installation, replication, `pg_hba.conf` template
- Use `ansible-vault` for all passwords in inventory variables

## PostgreSQL On-Premise
- Primary + at least one streaming replica
- `archive_mode = on` for WAL archiving to network storage
- Replication user with `REPLICATION` role attribute
- Automated daily backups to NFS or MinIO

## Monitoring (Prometheus + Grafana)
- `kube-prometheus-stack` Helm chart: Prometheus + Grafana + AlertManager + node-exporter
- `ServiceMonitor` CRDs for scraping application `/metrics` endpoints
- AlertManager → Slack webhook for all `warning` severity alerts

## Backup (Velero)
- Velero with MinIO (S3-compatible local object storage) as backup target
- Daily backup schedule for production namespace; 30-day retention
- Test restore process monthly

## Security Rules
- No direct SSH from internet; use VPN or bastion
- Kubernetes API server not exposed outside VPN
- Network policies: deny all inter-namespace traffic by default
- Pod Security Standards: `restricted` profile for production
- RBAC: service accounts least privilege; no `cluster-admin` for app pods
- Vault for all secrets; never plaintext K8s Secrets for sensitive values
- etcd encrypted at rest; backed up daily
