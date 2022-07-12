variable "project_id" {
    type = string
    description = "Project ID where the resources will be deployed"
}

variable "region" {
    type = string
    description = "Region where regional resources will be deployed"
}

variable "cluster_names" {
    type = set(string)
    description = "Names of the clusters to create"
}

variable "teams" {
    type = map(string)
    description = "Map with team names as string and ci-pipeline-configuration path in value"
}

variable "targets" {
    type = list(string)
    description = "List of targets for delivery in order of deployment stages"
}