provider "google-beta" {
    region      = var.region
    project     = var.project
}

provider "google" {
    region      = var.region
    project     = var.project  
}

data "google_project" "project" {
  project_id = var.project
}

# Service account used by Dyson
resource "google_service_account" "dyson" {
  project      = var.project
  account_id   = "dyson-sa"
  display_name = "dyson-sa"
}

# Grant the Dyson SA Pub/Sub Editor
resource "google_project_iam_member" "pub-sub-role" {
  project            = var.project
  role               = "roles/pubsub.editor"
  member             = "serviceAccount:${google_service_account.dyson.email}"
}


#Cloud Run Service 
resource "google_cloud_run_service" "dyson-deploy" {
  name     = "dyson-sample-deployment"
  location = var.region
  project = var.project

  template {
    spec {
      service_account_name = google_service_account.dyson.email
      timeout_seconds = 900
      containers {
        image = var.container_location
        env {
          name = "SYMBOL"
          value = var.topic
        }
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true
}

#Allow all users to call Cloud Run
resource "google_cloud_run_service_iam_member" "allUsers" {
  service  = google_cloud_run_service.dyson-deploy.name
  location = google_cloud_run_service.dyson-deploy.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}