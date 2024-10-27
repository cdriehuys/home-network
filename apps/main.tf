terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "cdriehuys-lan"
    workspaces {
      name = "homelab-apps"
    }
  }

  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "~> 7"
    }
  }
}

provider "argocd" {
  server_addr = var.argocd_server
  auth_token  = var.argocd_token
}

resource "argocd_repository" "home_network" {
  type = "git"
  repo = "https://github.com/cdriehuys/home-network.git"
}

resource "argocd_application" "apps" {
  for_each = var.apps

  metadata {
    name      = each.key
    namespace = "argocd"
  }

  spec {
    info {
      name  = "Description"
      value = "Managed by Terraform"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = each.value.namespace
    }

    source {
      repo_url        = argocd_repository.home_network.repo
      target_revision = each.value.revision
      path            = each.value.path
    }

    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }

      sync_options = ["CreateNamespace=true"]
    }
  }
}
