variable "argocd_server" {
  type        = string
  description = "ArgoCD endpoint"
}

variable "argocd_token" {
  type        = string
  description = "ArgoCD auth token"
}

variable "apps" {
  type = map(object({
    namespace = string
    path      = string
    revision  = optional(string, "HEAD")
  }))
  description = "Applications to deploy"

  default = {
    "flight-school" = {
      namespace = "flight-school"
      path      = "apps/flight-school"
    }
    "grafana" = {
      namespace = "monitoring"
      path      = "apps/grafana"
    }
    "homepage" = {
      namespace = "homepage"
      path      = "apps/homepage"
    }
    "node-exporter" = {
      namespace = "monitoring"
      path      = "apps/node-exporter"
    }
    "postgres" = {
      namespace = "postgres"
      path      = "apps/postgres"
    }
    "prometheus" = {
      namespace = "monitoring"
      path      = "apps/prometheus"
    }
    "prowlarr" = {
      namespace = "media"
      path      = "apps/prowlarr"
    }
    "radarr" = {
      namespace = "media"
      path      = "apps/radarr"
    }
    "sabnzbd" = {
      namespace = "media"
      path      = "apps/sabnzbd"
    }
    "sealed-secrets" = {
      namespace = "kube-system"
      path      = "apps/sealed-secrets"
    }
    "sonarr" = {
      namespace = "media"
      path      = "apps/sonarr"
    }
  }
}
