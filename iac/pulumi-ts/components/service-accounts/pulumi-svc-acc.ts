import { projectId, projectOwner } from "../../config"
import api from "../api"
import { IAMBinding } from "@pulumi/gcp/projects";
import { interpolate } from "@pulumi/pulumi";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";

export const createPulumiServiceAccount = () => {
    const pulumiServiceAccount = new ServiceAccount("pulumi", { accountId: "pulumi", project: projectId }, { dependsOn: [api.iam, api.cloudresourcemanager,] })
    new IAMBinding("pulumi-owner", {
        members: [interpolate`serviceAccount:${pulumiServiceAccount.email}`, `user:${projectOwner}`],
        role: "roles/owner",
        project: projectId,
    })
    return pulumiServiceAccount
}
