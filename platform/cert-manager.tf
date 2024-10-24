variable "email" {
  type        = string
  description = "Email address used for Let's Encrypt notifications"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token used to solve DNS challenges"
}

locals {
  cert_manager_namespace       = "cert-manager"
  cloudflare_token_secret_name = "cloudflare-api-token-secret"
}

resource "helm_release" "cert_manager" {
  depends_on = [helm_release.cilium]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.16.1"

  namespace        = local.cert_manager_namespace
  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = local.cloudflare_token_secret_name
    namespace = local.cert_manager_namespace
  }

  type = "Opaque"

  data = {
    "api-token" = var.cloudflare_api_token
  }
}

resource "kubernetes_manifest" "issuer_acme_staging" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }

    spec = {
      acme = {
        email  = var.email
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "issuer-letsencrypt-staging-account-key"
        }

        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = local.cloudflare_token_secret_name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "issuer_acme_production" {
  depends_on = [helm_release.cert_manager]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }

    spec = {
      acme = {
        email  = var.email
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = "issuer-letsencrypt-production-account-key"
        }

        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = local.cloudflare_token_secret_name
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "wilcard_cert" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "lan-wildcard"
      namespace = "default"
    }

    spec = {
      secretName = "lan-wildcard-tls"
      dnsNames   = ["proxy2.lan.qidux.com", "*.proxy2.lan.qidux.com"]
      issuerRef = {
        name = "letsencrypt-production"
        kind = "ClusterIssuer"
      }
    }
  }
}

