variable "project_id" {
    type = string
    description = "Project ID where the resources will be deployed"
}

variable "region" {
    type = string
    description = "Region where regional resources will be deployed"
}

variable "container_registry" {
    type = object({
        location = string
        project = string
        repository_id = string
    })
    description = "Container registry object"
}

variable "cluster_name" {
    type = string
    description = "Name of the cluster to be created"
}