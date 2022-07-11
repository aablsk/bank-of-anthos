import api from "../api";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { project } from "@pulumi/google-native/config";
import { IAMBinding } from "@pulumi/gcp/projects";
import { serviceaccount } from "@pulumi/gcp"
import { interpolate } from "@pulumi/pulumi";


export const createCloudBuildServiceAccount = (cloudDeployServiceAccount: ServiceAccount) => {
    const cloudBuildServiceAccount = new ServiceAccount("cloud-build", { accountId: "cloud-build", project: project }, { dependsOn: [api.iam] })

    new IAMBinding("cloudbuild-releaser", {
        members: [interpolate`serviceAccount:${cloudBuildServiceAccount.email}`],
        role: "roles/clouddeploy.releaser",
        project: project as string,
    }, { dependsOn: [api.clouddeploy, cloudBuildServiceAccount] });

    new serviceaccount.IAMBinding("cloudbuild-clouddeploy", {
        serviceAccountId: cloudDeployServiceAccount.name,
        members: [interpolate`serviceAccount:${cloudBuildServiceAccount.email}`],
        role: "roles/iam.serviceAccountUser",
    }, { dependsOn: [api.clouddeploy, cloudBuildServiceAccount, cloudDeployServiceAccount] });

    return cloudBuildServiceAccount;
}