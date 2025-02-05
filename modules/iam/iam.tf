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

# Service account for the Bastion NFS VM - limit scope for VM rather than use default compute SA
resource "google_service_account" "nfs_vm_service_account" {
  account_id   = "nfs-vm-service-account"
  display_name = "NFS VM Service Account"
}

# Service account for Bitbucket pipelines
resource "google_service_account" "bitbucket_service_account" {
  account_id   = "bitbucket-service-account"
  display_name = "Bitbucket Service Account"
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
# Generate and download the service account key in JSON format
resource "google_service_account_key" "bitbucket_service_account_key" {
  service_account_id = google_service_account.bitbucket_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
  depends_on         = [google_service_account.bitbucket_service_account]
}

# Store the service account key as a file
resource "local_file" "bitbucket_service_account_key_file" {
  filename = "${path.module}/${var.env}-${var.project}-bitbucket-service-account-key.json"
  content  = google_service_account_key.bitbucket_service_account_key.private_key
  depends_on = [google_service_account_key.bitbucket_service_account_key]
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

/* Uncomment this to bind the custom example role created abocve - account must be registered with GCP
# Assign the custom IAM roles 
resource "google_project_iam_binding" "frontend_role_binding" {
  project = "${var.project}"
  role    = google_project_iam_custom_role.frontend_role.name
  members = [
    "user:example@something.com",
    "user:example@something.com",
  ]
  depends_on = [google_project_iam_custom_role.frontend_role]
}
*/