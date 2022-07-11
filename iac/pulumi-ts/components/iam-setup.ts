import { createPulumiServiceAccount } from "./service-accounts/pulumi-svc-acc"
import { createGkeWorkloadServiceAccount } from "./service-accounts/gke-workload-svc-acc"
import { createCloudDeployServiceAccount } from "./service-accounts/cloud-deploy-svc-acc"
import { createCloudBuildServiceAccount } from "./service-accounts/cloud-build-svc-acc"
import { setupGkeNodeServiceAccountPermissions } from "./service-accounts/gke-node-svc-acc"
import { getProject } from "@pulumi/google-native/cloudresourcemanager/v1"
import { project } from "@pulumi/google-native/config"
import { IAMBinding } from "@pulumi/gcp/projects"
import { projectId, projectOwner } from "../config"
import api from "./api"
import { interpolate } from "@pulumi/pulumi"

export const setupIam = () => {
    const pulumiServiceAccount = createPulumiServiceAccount()
    const gkeServiceAccount = createGkeWorkloadServiceAccount()
    const cloudDeployServiceAccount = createCloudDeployServiceAccount()
    const cloudBuildServiceAccount = createCloudBuildServiceAccount(cloudDeployServiceAccount)
    const projectInfo = getProject({ project: project });
    new IAMBinding("logWriter", {
        members: [
            projectInfo.then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),
            interpolate`serviceAccount:${cloudBuildServiceAccount.email}`,
            interpolate`serviceAccount:${cloudDeployServiceAccount.email}`,
            `user:${projectOwner}`
        ],
        role: "roles/logging.logWriter",
        project: projectId,
    }, { dependsOn: [api.iam] })
    setupGkeNodeServiceAccountPermissions()
    return { gkeServiceAccount, cloudDeployServiceAccount, cloudBuildServiceAccount }
}