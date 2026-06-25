```markdown
# Pulse — Technical Infrastructure Specification

> **An automated Kubernetes deployment platform on AWS EKS utilizing declarative GitOps and self-healing canary routing.**

This repository contains the complete declarative manifests, environment initialization files, and routing specifications powering **Pulse**. 

🔗 **Live Portfolio Specification:** `https://YOONSEO99.github.io/pulse/`

---

## 🎨 System Architecture Overview

Pulse isolates application runtimes within a highly secure, private multi-AZ networking topology on AWS. 

* **Traffic Routing:** A single external Application Load Balancer (ALB) terminates HTTPS traffic and forwards requests to an internal **Nginx Ingress Controller** which dynamically splits traffic into `Stable` and `Canary` slots.
* **Cost & Security Optimization:** Outbound pods inside private subnets route to Amazon S3 exclusively through an isolated **AWS VPC Gateway Endpoint**, eliminating NAT Gateway data transfer charges and keeping data off the public internet.

---

## 📂 Repository Structure

```text
.
├── minikube/                   # Local sandbox bootstrapping & namespace initialization files
│   ├── .terraform.lock.hcl     # Terraform provider lock file
│   ├── terraform.tfstate       # Local state tracking for the Minikube test environment
│   ├── terraform.tfstate.backup
│   └── main.tf                 # Terraform script for initial local namespace setup
├── test-zone/                  # Experimental directory for candidate manifest testing
├── analysis-template.yaml      # Prometheus live metric analysis loop engine (AWS EKS)
├── ingress.yaml                # Nginx Ingress path-based routing specification (AWS EKS)
├── pulse-web.yaml              # Argo Rollouts canary deployment controller specification (AWS EKS)
└── README.md                   # Technical infrastructure specification documentation

```

---

## 🚀 Declarative Self-Healing Specification

### 🎯 Canary Rollout (`pulse-web.yaml`)

Manages the application lifecycle by initiating a `50%` traffic split upon a Git commit tag shift. It replaces the classic human-triggered manual pause gate with a fully automated telemetry analysis block.

### 📊 Telemetry Analysis (`analysis-template.yaml`)

Leverages a zero-tolerance Prometheus metric evaluator named `pulse-error-rate-check`. It directly queries live container telemetry via native PromQL HTTP APIs every 10 seconds.

```yaml
# Core validation loop engine snippet
metrics:
  - name: error-count
    interval: 10s
    count: 1
    successCondition: result[0] == 0
    failureLimit: 0
    provider:
      prometheus:
        address: [http://prometheus-server.monitoring.svc.cluster.local:80](http://prometheus-server.monitoring.svc.cluster.local:80)
        query: "sum(delta(pulse_http_requests_total{status=~\"5.*\"}[10s])) or vector(0)"

```

---

## 🎬 Operational Demo Scenarios

The platform proves its architectural robustness through three fully-documented validation runs (Demo clips are viewable on the main technical specification site):

1. **Scenario 01: Automated Rollback Based on Real-Time Metrics**
* **Behavior:** Faulty code pushes trigger immediate HTTP 5xx errors. Prometheus captures the anomaly, breaches the threshold, and Argo Rollouts drops traffic back to the safe version in `< 1s`.


2. **Scenario 02: Successful Canary Release Using Inline Metrics**
* **Behavior:** Stable code releases maintain a perfect `0` error delta. The analysis engine validates runtime stability over the evaluation window and automatically promotes the rollout to `100%` traffic coverage with zero downtime.


3. **Scenario 03: Manual Promotion & Pause Gate Control**
* **Behavior:** Suspends the rollout at a designated `50%` checkpoint, establishing a human-in-the-loop security gate. The deployment waits statically until a cluster engineer reviews platform metrics and issues a manual `Resume` command via the Argo CD UI.



---

## 🛠️ Technology Stack & Core Rationale

* **AWS EKS & EC2 (t3.medium):** Hosts the container workloads with multi-AZ node resiliency. Managed group scaling allows network interfaces (ENIs) to match maximum predictable container dense capacities.
* **Argo CD & Argo Rollouts:** Drives the GitOps paradigm. Eliminates configuration drift by synchronizing actual runtime states with declarative manifests stored inside this repository.
* **Prometheus Telemetry:** Pull-based metric engine operating at an aggressive 10-second scrape interval to act as the automated rollback execution judge.
* **Helm & GitHub Actions:** Version-controls manifest properties into unified charts while executing standardized automated build tags to container registries (Docker Hub).

---


