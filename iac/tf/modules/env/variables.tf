variable "project_id" {
    type = string
    description = "Project ID where the resources will be deployed"
}

variable "region" {
    type = string
    description = "Region where regional resources will be deployed"
}

variable "env_name" {
    type = string
    description = "Name of the environment to be created"
}

variable "gke" {
    type = object({
        name: string,
        location: string,
    })
    description = "GKE cluster to initialize with ACM & ASM"
}