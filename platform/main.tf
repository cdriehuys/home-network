terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "cdriehuys-lan"
    workspaces {
      name = "homelab-platform"
    }
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "./.kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "./.kubeconfig"
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.17.0"

  namespace        = "cilium"
  create_namespace = true

  set {
    name  = "operator.replicas"
    value = "1"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }
}

locals {
  argocd_namespace = "argocd"
  argocd_provisioner = "provisioner"

  argocd_rbac_policy = <<EOF
g, ${local.argocd_provisioner}, role:admin
EOF
}

resource "helm_release" "argocd" {
  depends_on = [helm_release.cilium]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.6.9"

  namespace = local.argocd_namespace
  create_namespace = true

  set_list {
    name  = "server.extraArgs"
    value = ["--insecure"]
  }

  set {
    name  = "global.domain"
    value = "argocd.proxy2.lan.qidux.com"
  }

  set {
    name = "configs.cm.accounts\\.${local.argocd_provisioner}"
    value = "apiKey\\, login"
  }

  set {
    name = "configs.rbac.policy\\.csv"
    value = replace(local.argocd_rbac_policy, ",", "\\,")
  }
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = local.argocd_namespace
  }

  spec {
    rule {
      host = "argocd.proxy2.lan.qidux.com"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }

    tls {
      hosts = ["argocd.proxy2.lan.qidux.com"]
      secret_name = "lan-wildcard-tls"
    }
  }
}
