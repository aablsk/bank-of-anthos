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

variable "source_repository" {
    type = object({
        name = string
        project = string
    })
    description = "Name of the source repository to clone from"
}

variable "team" {
    type = string
    description = "Name of the team"
}

variable "pipeline_definition_filename" {
    type = string
    description = "Name of the file containing the cloud build pipeline definition. Relative path from repository root"
}

variable "targets" {
    type = list(string)
    description = "List of the target names that shall be deployed to in order of deployment stages"
}

variable "clusters" {
    type = map(object({
        cluster = object({
            location = string
            id = string
        })
    }))
    description = "Clusters that have been created and shall be used as targets. Keys must be a superset of targets list."
}