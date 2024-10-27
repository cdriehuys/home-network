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

resource "kubernetes_persistent_volume_claim" "nfs_media" {
  metadata {
    name = "nfs-media"
    namespace = "media"
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
