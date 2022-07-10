import { createPulumiServiceAccount } from "./service-accounts/pulumi-svc-acc"
import { createGkeWorkloadServiceAccount } from "./service-accounts/gke-workload-svc-acc"
import { createCloudDeployServiceAccount } from "./service-accounts/cloud-deploy-svc-acc"
import { createCloudBuildServiceAccount } from "./service-accounts/cloud-build-svc-acc"
import { setupGkeNodeServiceAccountPermissions } from "./service-accounts/gke-node-svc-acc"

export const setupIam = () => {
    const pulumiServiceAccount = createPulumiServiceAccount()
    const gkeServiceAccount = createGkeWorkloadServiceAccount()
    const cloudDeployServiceAccount = createCloudDeployServiceAccount()
    const cloudBuildServiceAccount = createCloudBuildServiceAccount(cloudDeployServiceAccount)
    setupGkeNodeServiceAccountPermissions()
    return { gkeServiceAccount, cloudDeployServiceAccount, cloudBuildServiceAccount }
}