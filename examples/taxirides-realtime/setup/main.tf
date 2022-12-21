provider "google" {
    region      = var.region
    project     = var.project
}

data "google_project" "project" {
  project_id = var.project
}

# IAM permissions for cloudbuild to use K8s
resource "google_project_iam_member" "cloud_build_GKE_iam" {
  project = data.google_project.project.number
  role    = "roles/container.developer"
  member  = join("",["serviceAccount:",data.google_project.project.number,"@cloudbuild.gserviceaccount.com"])
}

resource "google_project_iam_member" "compute_default" {
  project = data.google_project.project.number
  role    = "roles/artifactregistry.reader"
  member  = join("",["serviceAccount:",data.google_project.project.number,"-compute@developer.gserviceaccount.com"]) 
}

resource "google_container_cluster" "dyson_cluster" {
  name     = "dyson-cluster"
  location = var.region
 
# Enabling Autopilot for this cluster
  enable_autopilot = true
#   
  ip_allocation_policy {
  }
}

# Workload Identity IAM binding for Dyson in default namespace.
resource "google_service_account_iam_member" "dyson-sa-workload-identity" {
  service_account_id = google_service_account.dyson.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project}.svc.id.goog[dyson/dyson-taxirides]"
  depends_on = [
    google_container_cluster.dyson_cluster
  ]
}

#Role for Pub/Sub
resource "google_project_iam_member" "pub-sub-role" {
  project            = var.project
  role               = "roles/pubsub.editor"
  member             = "serviceAccount:${google_service_account.dyson.email}"
}

# Service account used by Dyson
resource "google_service_account" "dyson" {
  project      = var.project
  account_id   = "dyson-sa"
  display_name = "dyson-sa"
}