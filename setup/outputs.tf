output "gkeZone" {
    value = google_container_cluster.dyson_cluster.zone
}

output "project" {
    value = google_container_cluster.dyson_cluster.project
}

output "location" {
    value = google_container_cluster.dyson_cluster.location
}
