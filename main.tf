# 1. 사용할 도구(Provider) 선언
terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~>2.24.0"
        }
    }
}

# 2. 미니쿠베 쿠버네티스 기지 주소 알려주기
provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "minikube"
}

# 3. Pulse 전용 Namespace 만들기
resource "kubernetes_namespace" "pulse_space" {
    metadata{
        name = "pulse"
    }
}