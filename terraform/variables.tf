variable "region" {
    type        = string
    description = "Default region for GCP resources"
    default     = "us-central1"
}

variable "project" {
    type        = string
    description = "The project in which to place all new resources"
}

variable "topic" {
    type        = string
    default     = "projects/pubsub-public-data/topics/taxirides-realtime"
    description = "The Pub/Sub topic you wish to expose via the Websocket"
}

variable "container_location" {
    type        = string
    default     = "gcr.io/gcp-autosocket/autosocket:latest"
    description = "Location of the container image" 
}