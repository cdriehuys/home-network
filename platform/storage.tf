resource "kubernetes_persistent_volume" "nfs_media" {
  metadata {
    name = "nfs-media"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-shared"
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      nfs {
        path   = "/mnt/Primary/Media"
        server = "freenas.lan.qidux.com"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "backups" {
  metadata {
    name = "nfs-media-backups"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-shared"
    capacity = {
      storage = "1Gi"
    }
    persistent_volume_source {
      nfs {
        path   = "/mnt/Primary/backups/media-downloaders"
        server = "freenas.lan.qidux.com"
      }
    }
  }
}

resource "kubernetes_namespace" "media" {
  metadata {
    name = "media"
  }
}

resource "kubernetes_persistent_volume_claim" "nfs_media_backups" {
  metadata {
    name = "nfs-media-backups"
    namespace = kubernetes_namespace.media.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-shared"
    volume_name        = "nfs-media-backups"

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "nfs_media" {
  metadata {
    name = "nfs-media"
    namespace = kubernetes_namespace.media.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-shared"
    volume_name        = "nfs-media"

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}
