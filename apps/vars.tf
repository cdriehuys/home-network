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
    revision = optional(string, "HEAD")
  }))
  description = "Applications to deploy"

  default = {
    "grafana" = {
      namespace = "monitoring"
      path      = "apps/grafana"
      revision = "grafana"
    }
    "homepage" = {
      namespace = "homepage"
      path      = "apps/homepage"
    }
    "node-exporter" = {
      namespace = "monitoring"
      path      = "apps/node-exporter"
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
    "sonarr" = {
        namespace = "media"
        path      = "apps/sonarr"
    }
  }
}
