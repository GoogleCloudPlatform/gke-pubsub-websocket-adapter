variable "region" {
    type        = string
    description = "Default region for GCP resources"
    default     = "us-central1"
}

variable "zone" {
    type        = string
    description = "Default zone for GCP resources"
    default     = "us-central1-f"
}

variable "project" {
    type        = string
    description = "The project in which to place all new resources"
}
