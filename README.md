# concept

A Spring Boot REST API demonstrating a production-grade GitOps deployment pipeline with ArgoCD, Helm, and Istio on Kubernetes.

## Stack

| Layer | Technology |
|---|---|
| Runtime | Java 21, Spring Boot 4.1.0 |
| Build | Maven, Docker (multi-stage) |
| Registry | GitHub Container Registry (GHCR) |
| CI | GitHub Actions |
| CD | ArgoCD (GitOps) |
| Packaging | Helm |
| Service mesh | Istio |
| Autoscaling | Horizontal Pod Autoscaler |

## API

| Method | Path | Description |
|---|---|---|
| GET | `/hello` | Returns a hello world message |
| GET | `/actuator/health` | Health check (liveness + readiness) |

### Example

```bash
curl http://localhost:8080/hello
# {"message":"Hello World"}
```

## Local development

**Prerequisites:** Java 21, Maven

```bash
# Run
./mvnw spring-boot:run

# Test
./mvnw test

# Build JAR
./mvnw clean package -DskipTests
```

App starts on `http://localhost:8080`.

## Docker

```bash
docker build -t concept .
docker run -p 8080:8080 concept
```

## Project structure

```
.
├── src/                          # Application source
├── helm/                         # Helm chart (ArgoCD syncs this)
│   ├── Chart.yaml
│   ├── values.yaml               # Tunable config (image tag updated by CI)
│   └── templates/
│       ├── deployment.yaml       # Kubernetes Deployment
│       ├── service.yaml          # ClusterIP Service
│       ├── hpa.yaml              # Horizontal Pod Autoscaler
│       ├── destinationrule.yaml  # Istio traffic policy + circuit breaker
│       └── virtualservice.yaml   # Istio ingress routing
├── argocd/
│   ├── deployment.yaml           # ArgoCD Application template (envsubst)
│   └── rendered-deployment.yaml  # Rendered by CI — apply once to bootstrap
└── .github/workflows/
    └── build-deploy.yml          # CI/CD pipeline
```

## CI/CD pipeline

On every push to `main`:

1. Build JAR with Maven
2. Build and push Docker image to GHCR (`ghcr.io/<owner>/concept:<sha>`)
3. Render the ArgoCD Application manifest (`argocd/rendered-deployment.yaml`)
4. Update `helm/values.yaml` with the new image tag
5. Commit and push — ArgoCD detects the change and syncs the cluster

All pipeline variables are defined at the top of `build-deploy.yml`:

| Variable | Value | Description |
|---|---|---|
| `APP_NAME` | `github.event.repository.name` | ArgoCD app name |
| `REPO_URL` | `github.server_url/github.repository.git` | Source repo for ArgoCD |
| `TARGET_REVISION` | `github.ref_name` | Branch ArgoCD tracks |
| `HELM_PATH` | `helm` | Path to Helm chart in repo |
| `DESTINATION_NAMESPACE` | `github.event.repository.name` | Kubernetes namespace |
| `ARGOCD_NAMESPACE` | `argocd` | Namespace where ArgoCD runs |
| `ARGOCD_PROJECT` | `default` | ArgoCD project |

## Kubernetes deployment

### Bootstrap ArgoCD (once)

After cloning, render and apply the ArgoCD Application manifest:

```bash
# Render with your env vars
export APP_NAME=concept
export REPO_URL=https://github.com/<owner>/concept.git
export TARGET_REVISION=main
export HELM_PATH=helm
export DESTINATION_NAMESPACE=concept
export ARGOCD_NAMESPACE=argocd
export ARGOCD_PROJECT=default

envsubst < argocd/deployment.yaml | kubectl apply -f -
```

Or use the pre-rendered file committed by CI:

```bash
kubectl apply -f argocd/rendered-deployment.yaml
```

### Helm values

Key values in `helm/values.yaml`:

```yaml
replicaCount: 2          # baseline replicas

hpa:
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

istio:
  enabled: true          # set false if not using Istio
  host: concept.example.com
```

### Health probes

Spring Boot Actuator exposes split probes used by Kubernetes:

| Probe | Path |
|---|---|
| Liveness | `/actuator/health/liveness` |
| Readiness | `/actuator/health/readiness` |
