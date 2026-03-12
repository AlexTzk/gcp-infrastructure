resource "google_container_cluster" "primary" {
  name     = "${var.company}-${var.env}-gke"
  location = var.zone
  deletion_protection = false
  workload_identity_config {
      workload_pool = "${data.google_client_config.default.project}.svc.id.goog"
    }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_id
  subnetwork = var.privatenetwork_subnet

  private_cluster_config {
    enable_private_endpoint = true # this makes the public endpoint unreachable and private endpoint default
    enable_private_nodes    = true 
    master_ipv4_cidr_block  = "${var.gke_master_ipv4_cidr}"
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "${var.gke_cluster_ipv4_cidr}"
    services_ipv4_cidr_block = "${var.gke_services_ipv4_cidr}"
  }
  master_authorized_networks_config {
  dynamic "cidr_blocks" {
    for_each = var.authorized_networks
    content {
      cidr_block = cidr_blocks.key
      display_name = cidr_blocks.value
      }
    }
  }
}
# provision a managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name               = google_container_cluster.primary.name
  location           = "${var.zone}"
  cluster            = google_container_cluster.primary.name
  node_count         = "${var.gke_num_nodes}"
  autoscaling {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
    labels = {
      env  = "${var.env}"
      company = "${var.company}"
    }
    workload_metadata_config {
        mode = "GKE_METADATA"
    }
    machine_type = "${var.gke_machine_type}"
    preemptible  = false
    tags         = concat(
      ["gke-node"],
      ["${var.company}-${var.env}-gke"],
      [var.gke_lb_target_tag]
    )
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# data source to retrieve cluster info
data "google_container_cluster" "primary" {
  name     = google_container_cluster.primary.name
  location = var.zone
  depends_on = [google_container_cluster.primary]
}
data "google_client_config" "default" {}

# Configure the Kubernetes provider using the cluster info
provider "kubernetes" {
  # Prepend "https://" to ensure the host is a valid URL
  host = "https://${data.google_container_cluster.primary.endpoint}"

  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  )

  # Use the current client's access token for authentication
  token = data.google_client_config.default.access_token
}

# create kubernetes SA
resource "kubernetes_service_account_v1" "cloud_sql_proxy" {
  metadata {
    name      = "cloud-sql-proxy"
    namespace = "default"
    annotations = {
      # Map the Kubernetes SA to your Cloud SQL SA
      "iam.gke.io/gcp-service-account" = var.gke_cloudsql_sa
    }
  }

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}

# Helm provider to pull GKE cluster info
provider "helm" {
  kubernetes = {
    host                   = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Create namespace
resource "kubernetes_namespace_v1" "nginx_ingress" {
  metadata {
    name = "ingress-nginx"
  }
}

# Add NGINX ingress for NEG HTTPS LB backend
// secondary one could be added for an internal NGINX controller 
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace_v1.nginx_ingress.metadata[0].name
  values = [file("${path.module}/values.yaml")]
  depends_on = [
    kubernetes_namespace_v1.nginx_ingress,
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes
  ]
}

# GKE external secrets
resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

# add a gke SA for external secrets with workload identity
resource "kubernetes_service_account_v1" "external_secrets" {
  metadata {
    name      = "external-secrets-sa"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = var.gke_external_secrets_sa
    }
  }

  depends_on = [
    google_container_node_pool.primary_nodes,
    kubernetes_namespace_v1.external_secrets
  ]
}

# add external secrets operator so we don't leak secrets to tfstate 
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace_v1.external_secrets.metadata[0].name

  values = [yamlencode({
    serviceAccount = {
      create = false
      name   = kubernetes_service_account_v1.external_secrets.metadata[0].name
    }
  })]

  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_nodes,
    kubernetes_namespace_v1.external_secrets,
    kubernetes_service_account_v1.external_secrets
  ]
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  load_config_file       = false
}

resource "kubectl_manifest" "gcp_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "gcp-secret-store"
      namespace = "default"
    }
    spec = {
      provider = {
        gcpsm = {
          projectID = var.project
          auth = {
            workloadIdentity = {
              clusterLocation = var.zone
              clusterName     = google_container_cluster.primary.name
              serviceAccountRef = {
                name      = kubernetes_service_account_v1.external_secrets.metadata[0].name
                namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
              }
            }
          }
        }
      }
    }
  })
  depends_on = [helm_release.external_secrets]
}

# gke manifest for pg secrets
resource "kubectl_manifest" "postgres_external_secret" {
  yaml_body = yamlencode ({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "postgres"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "gcp-secret-store"
        kind = "SecretStore"
      }
      target = {
        name           = "postgres"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "pguser"
          remoteRef = {
            key = var.db_user_secret_name
          }
        },
        {
          secretKey = "pgpass"
          remoteRef = {
            key = var.db_password_secret_name
          }
        },
        {
          secretKey = "pgdb"
          remoteRef = {
            key = var.db_name_secret_name
          }
        }
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubectl_manifest.gcp_secret_store
  ]
}