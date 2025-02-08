provider "google" {
  project = var.project
  region  = var.region
}

resource "google_cloud_run_v2_service" "frontend_app" {
  name     = "${var.env}-my-app"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
  client = "gcloud"
  client_version = "501.0.0"

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    scaling {
      min_instance_count = 0 # may want to increase to 1 or more if you don't want cold starts
      max_instance_count = 1 # max number of instances
    }
    containers {
      image = "nginxdemos/hello:0.4"
      name = "my-app"
      ports {
        container_port = 80
      }
      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }
      startup_probe {
        initial_delay_seconds = 10
        timeout_seconds      = 3
        period_seconds       = 10
        failure_threshold    = 2
        tcp_socket {
          port = 80
        }
      }
    }
  }
}
 data "google_iam_policy" "noauth" {
   binding {
     role = "roles/run.invoker"
     members = ["allUsers"]
   }
 }

 resource "google_cloud_run_service_iam_policy" "noauth" {
   location    = google_cloud_run_v2_service.frontend_app.location
   project     = google_cloud_run_v2_service.frontend_app.project
   service     = google_cloud_run_v2_service.frontend_app.name

   policy_data = data.google_iam_policy.noauth.policy_data
 }

resource "google_project_service" "artifact_registry" {
  project = "${var.project}"
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "my-app" {
  repository_id = "${var.env}-my-app"
  project       = "${var.project}"
  location      = "${var.region}"
  format        = "DOCKER"
}
