import api from "../api";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { project } from "@pulumi/google-native/config";
import { IAMBinding } from "@pulumi/gcp/projects";
import { interpolate } from "@pulumi/pulumi";


export const createCloudDeployServiceAccount = () => {
    const serviceAccount = new ServiceAccount("cloud-deploy", { accountId: "cloud-deploy", project: project }, { dependsOn: [api.iam] })

    new IAMBinding("clouddeploy-logWriter", {
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: "roles/logging.logWriter",
        project: project as string,
    }, { dependsOn: [api.iam, serviceAccount] });

    new IAMBinding("clouddeploy-gcs-reader", {
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: "roles/storage.objectViewer",
        project: project as string,
    }, { dependsOn: [api.iam, serviceAccount] });

    new IAMBinding("clouddeploy-k8s", {
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: "roles/container.developer",
        project: project as string,
    }, { dependsOn: [api.iam, api.containers, serviceAccount] });

    return serviceAccount;
}