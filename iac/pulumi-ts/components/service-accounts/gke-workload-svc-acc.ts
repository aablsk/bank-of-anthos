import { projectId } from "../../config"
import api from "../api"
import { ServiceAccount } from "@pulumi/google-native/iam/v1"
import { IAMBinding } from "@pulumi/gcp/projects";
import { interpolate } from "@pulumi/pulumi";
import { serviceaccount } from "@pulumi/gcp";
import { project } from "@pulumi/google-native/config";

export const createGkeWorkloadServiceAccount = () => {
    const serviceAccount = new ServiceAccount("gke-workload", { accountId: "gke-workload", project: projectId }, { dependsOn: [api.iam] })
    new IAMBinding("cloudTraceAgent", {
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: "roles/cloudtrace.agent",
        project: projectId,
    })
    new serviceaccount.IAMBinding("gke-workload-identity", {
        serviceAccountId: serviceAccount.name,
        members: [`serviceAccount:${project}.svc.id.goog[default/default]`],
        role: "roles/iam.workloadIdentityUser"
    })

    return serviceAccount
}