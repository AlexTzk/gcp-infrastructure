provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
}

# SSL Certificate
resource "google_compute_ssl_certificate" "ssl_cert" {
  name        = "certs-tls-25-tf"
  project     = var.project
  private_key = file("${path.module}/mycert.key")
  certificate = file("${path.module}/mycert.crt")
}

# Cloud Run NEG
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "myapp-frontend-${var.env}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = "${var.env}-my-app"
  }
}

# GKE NEG Configuration
resource "google_compute_network_endpoint_group" "gke_neg" {
  name                  = "${var.env}-gke-neg"
  network		= var.network_id
  subnetwork            = var.privatenetwork_subnet
  network_endpoint_type = "GCE_VM_IP_PORT"
  zone                  = var.zone
}

# GKE BE for LB
resource "google_compute_backend_service" "gke_backend_service" {
  name                    = "${var.env}-gke-backend-service"
  project                 = var.project
  load_balancing_scheme   = "EXTERNAL"
  protocol                = "HTTPS"
  timeout_sec             = 30
  health_checks           = [google_compute_health_check.gke_health_check.self_link]
  connection_draining_timeout_sec = 300
  enable_cdn              = true
  custom_request_headers = ["X-Forwarded-For: {client_ip_address}"]
  custom_response_headers = [
    "Strict-Transport-Security: max-age=31536000; includeSubDomains; preload",
    "X-XSS-Protection: 1; mode=block",
    "X-Content-Type-Options: nosniff"
  ]
  backend {
    group                    = "projects/${var.project}/zones/${var.zone}/networkEndpointGroups/ingress-nginx-443-neg-https"
    balancing_mode           = "RATE"
    max_rate_per_endpoint    = 100
    capacity_scaler          = 1.0
  }

  cdn_policy {
    cache_mode          = "CACHE_ALL_STATIC"
    default_ttl         = 3600
    max_ttl             = 86400
    client_ttl          = 3600
    serve_while_stale   = 86400
    cache_key_policy {
      include_host         = true
      include_protocol     = true
      include_query_string = true
    }
  }
}

# HC for GKE BE
resource "google_compute_health_check" "gke_health_check" {
  name    = "${var.env}-gke-be-nginx-health-check"
  project = var.project

  https_health_check {
    port         = 443
    request_path = "/healthz"
  }

  timeout_sec        = 5
  check_interval_sec = 30
  healthy_threshold  = 1
  unhealthy_threshold = 3
}


# Backend Services
resource "google_compute_backend_service" "cloudrun_backend_service" {
  name        = "${var.env}-my-app-be"
  project     = var.project
  protocol    = "HTTPS"
  timeout_sec = 30
  connection_draining_timeout_sec = 300
  enable_cdn = true
  
  custom_request_headers = ["X-Forwarded-For: {client_ip_address}"]
  custom_response_headers = [
    "Strict-Transport-Security: max-age=31536000; includeSubDomains; preload",
    "X-XSS-Protection: 1; mode=block",
    "X-Content-Type-Options: nosniff"
  ]
  
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.self_link
  }

  cdn_policy {
    cache_mode                 = "CACHE_ALL_STATIC"
    default_ttl                 = 3600
    max_ttl                     = 86400
    client_ttl                  = 3600
    serve_while_stale           = 86400
    cache_key_policy {
      include_host           = true
      include_protocol       = true
      include_query_string   = true
    }
  }
}

# SSL Policy
resource "google_compute_ssl_policy" "ssl_policy" {
  provider        = google-beta
  name            = "ssl-policy"
  profile         = "RESTRICTED"
  min_tls_version = "TLS_1_2"
}

# URL Map with Path-Based Routing
resource "google_compute_url_map" "public_loadbalancer" {
  name    = "public-loadbalancer"
  project = "${var.project}"

  # Default backend service
  default_service = google_compute_backend_service.cloudrun_backend_service.self_link

  # Host Rules
  host_rule {
    hosts        = ["gke.mydomain.com", "gke2.mydomain.com"]
    path_matcher = "path-matcher-1"
  }

  host_rule {
    hosts        = ["app.mydomain.com"]
    path_matcher = "myapp-routes"
  }

  # Path Matchers
  path_matcher {
    name            = "myapp-routes"
    default_service = google_compute_backend_service.cloudrun_backend_service.self_link
  }

  path_matcher {
    name            = "path-matcher-1"
    default_service = google_compute_backend_service.gke_backend_service.self_link
  }
}


# Target Proxy
resource "google_compute_target_https_proxy" "https_lb_proxy" {
  name    = "${var.env}-gke-https-lb-proxy"
  ssl_certificates = [google_compute_ssl_certificate.ssl_cert.self_link]
  project = var.project
  url_map = google_compute_url_map.public_loadbalancer.self_link
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.env}-forwarding-rule"
  project               = var.project
  target                = google_compute_target_https_proxy.https_lb_proxy.self_link
  ip_address            = var.lb_ip
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
}
