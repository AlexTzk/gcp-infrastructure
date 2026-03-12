# Custom IAM role for Bitbucket
resource "google_project_iam_custom_role" "bitbucket_role" {
  role_id     = "bitbucket_role"
  title       = "Bitbucket Role"
  description = "Custom role for Bitbucket pipelines"
  permissions = [
    "container.clusters.get",
    "container.clusters.getCredentials",
    "container.deployments.get",
    "container.deployments.update",
    "container.ingresses.get",
    "container.ingresses.update",
    "container.services.get",
    "container.services.update",
    "container.statefulSets.get",
    "container.statefulSets.update",
    "run.services.get",
    "run.services.update",
    "storage.buckets.get",
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.list",
    "iam.serviceAccounts.getAccessToken",
  ]
}

# bastion VM SA account
resource "google_service_account" "bastion_vm_service_account" {
  account_id   = "bastion-vm-service-account"
  display_name = "Bastion VM Service Account"
}

# bastion VM privileges
resource "google_project_iam_member" "bastion_vm_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.bastion_vm_service_account.email}"
}

# Service account for the Bastion NFS VM
resource "google_service_account" "nfs_vm_service_account" {
  account_id   = "nfs-vm-service-account"
  display_name = "NFS VM Service Account"
}
locals {
  nfs_sa_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
  bastion_human_roles = [
      "roles/iap.tunnelResourceAccessor",
      "roles/compute.osLogin",
      "roles/compute.osAdminLogin"
    ]
}

# dedicated google secret accessor for ESO
resource "google_service_account" "external_secrets_sa" {
  account_id   = "gke-external-secrets-sa"
  display_name = "GKE External Secrets Operator SA"
}

resource "google_project_iam_member" "external_secrets_secret_accessor" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external_secrets_sa.email}"
}

resource "google_service_account_iam_member" "external_secrets_workload_binding" {
  service_account_id = google_service_account.external_secrets_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[external-secrets/external-secrets-sa]"
}

# Grant roles to Bastion NFS VM 
resource "google_project_iam_member" "nfs_vm_service_account_roles" {
  for_each = toset(local.nfs_sa_roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.nfs_vm_service_account.email}"
}

# Service account for GKE workloads that need to connect to Cloud SQL 
resource "google_service_account" "gke_cloudsql_sa" {
  account_id   = "gke-cloudsql-sa"
  display_name = "GKE Cloud SQL Service Account"
}

# Grant Cloud SQL Client permissions
resource "google_project_iam_member" "gke_cloudsql_sa_binding" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.gke_cloudsql_sa.email}"
}

# Bind Cloud SQL SA to Workload idnetity
resource "google_service_account_iam_member" "gke_cloudsql_sa_workload_binding" {
  service_account_id = google_service_account.gke_cloudsql_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[default/cloud-sql-proxy]"
}

# Service account for Bitbucket pipelines
resource "google_service_account" "bitbucket_service_account" {
  account_id   = "bitbucket-service-account"
  display_name = "Bitbucket Service Account"
}

# assign the group/members for the bastion vm
resource "google_project_iam_binding" "bastion_human_access" {
  for_each = toset(local.bastion_human_roles)
  project  = var.project
  role     = each.value
  members  = var.bastion_access_members
}

# Assign the custom IAM role to the service account
resource "google_project_iam_binding" "bitbucket_role_binding" {
  project = "${var.project}"
  role    = google_project_iam_custom_role.bitbucket_role.name
  members = [
    "serviceAccount:${google_service_account.bitbucket_service_account.email}",
  ]
}
resource "google_project_iam_binding" "bitbucket_role_binding_artifact" {
  project = "${var.project}"
  role    = "roles/artifactregistry.writer"
  members = [
    "serviceAccount:${google_service_account.bitbucket_service_account.email}",
  ]
}

# Workload identity pool for external CI/CD
resource "google_iam_workload_identity_pool" "bitbucket_pool" {
  workload_identity_pool_id = "${var.env}-bitbucket-pool"
  display_name              = "Bitbucket Pipelines Pool"
  description               = "OIDC trust for Bitbucket Pipelines"
  disabled                  = false
}

# Workload identity for GKe <-> Secret manager
resource "google_project_iam_member" "gke_cloudsql_sa_secret_accessor" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.gke_cloudsql_sa.email}"
}

# OIDC provider for Bitbucket Pipelines
resource "google_iam_workload_identity_pool_provider" "bitbucket_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.bitbucket_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.env}-bitbucket-provider"
  display_name                       = "Bitbucket OIDC Provider"
  description                        = "OIDC provider for Bitbucket Pipelines"
  disabled                           = false

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repositoryUuid"
    "attribute.workspace"  = "assertion.workspaceUuid"
    "attribute.branch"     = "assertion.branchName"
  }

  oidc {
    issuer_uri = "https://api.bitbucket.org/2.0/workspaces/${var.bitbucket_workspace}/pipelines-config/identity/oidc"
  }

  attribute_condition = "attribute.workspace == \"${var.bitbucket_workspace_uuid}\""
}

# Allow identities from Bitbucket OIDC pool to impersonate the SA
resource "google_service_account_iam_member" "bitbucket_wif_user" {
  service_account_id = google_service_account.bitbucket_service_account.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.bitbucket_pool.name}/attribute.workspace/${var.bitbucket_workspace_uuid}"
}

# Custom IAM role for Frontend developer
resource "google_project_iam_custom_role" "frontend_role" {
  role_id     = "frontend_role"
  title       = "Frontend Role"
  description = "Custom role for Frontend"
  permissions = [
    "run.services.get",
    "run.locations.get",
    "run.routes.get",
    "run.routes.list",
    "run.revisions.get",
    "run.revisions.list",
    "logging.logEntries.list",
    "logging.logs.list",
    "monitoring.timeSeries.list",
    "monitoring.metricDescriptors.list",
  ]
}

# frontend role assignment
resource "google_project_iam_binding" "frontend_role_binding" {
  count   = length(var.frontend_access_members) > 0 ? 1 : 0
  project = var.project
  role    = google_project_iam_custom_role.frontend_role.name
  members = var.frontend_access_members
}