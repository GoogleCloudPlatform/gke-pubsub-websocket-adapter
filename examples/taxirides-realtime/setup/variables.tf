variable "region" {
    type        = string
    description = "Default region for GCP resources"
    default     = "us-central1"
}

variable "project" {
    type        = string
    description = "The project in which to place all new resources"
}
