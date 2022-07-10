import * as pulumi from "@pulumi/pulumi";
import * as google_native from "@pulumi/google-native";
import api from "./api";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { artifactregistry } from "@pulumi/gcp";
import { project } from "@pulumi/google-native/config";
import { registryName, projectId } from "../config";
import { getProject } from "@pulumi/google-native/cloudresourcemanager/v1";

export const createArtifactRegistry = (gkeServiceAccount: ServiceAccount, cloudBuildServiceAccount: ServiceAccount) => {
    const artifactRegistry = new google_native.artifactregistry.v1.Repository("artifact-registry", {
        format: google_native.artifactregistry.v1.RepositoryFormat.Docker,
        repositoryId: registryName,
    }, {
        dependsOn: [api.artifactregistry, api.cloudresourcemanager],
    });

    new artifactregistry.RepositoryIamBinding("gke-pull", {
        repository: artifactRegistry.id,
        members: [pulumi.interpolate`serviceAccount:${gkeServiceAccount.email}`, getProject({ project: project }).then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),],
        role: "roles/artifactregistry.reader",
        project: project
    }, {
        dependsOn: [api.artifactregistry, gkeServiceAccount, artifactRegistry]
    })
    new artifactregistry.RepositoryIamBinding("cloudbuild", {
        repository: artifactRegistry.id,
        members: [pulumi.interpolate`serviceAccount:${cloudBuildServiceAccount.email}`],
        role: "roles/artifactregistry.writer",
        project: project
    }, {
        dependsOn: [api.artifactregistry, gkeServiceAccount, artifactRegistry]
    })

    return artifactRegistry;
}