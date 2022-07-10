import { projectId } from "../../config"
import api from "../api"
import { IAMBinding } from "@pulumi/gcp/projects";
import { getProject } from "@pulumi/google-native/cloudresourcemanager/v1";

export const setupGkeNodeServiceAccountPermissions = () => {
    const projectInfo = getProject({ project: projectId });
    new IAMBinding("logWriter", {
        members: [projectInfo.then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),],
        role: "roles/logging.logWriter",
        project: projectId,
    }, { dependsOn: [api.iam] })
    new IAMBinding("metricWriter", {
        members: [projectInfo.then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),],
        role: "roles/monitoring.metricWriter",
        project: projectId,
    }, { dependsOn: [api.iam] })
    new IAMBinding("monitoringViewer", {
        members: [projectInfo.then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),],
        role: "roles/monitoring.viewer",
        project: projectId,
    }, { dependsOn: [api.iam] })
    new IAMBinding("metaDataWriter", {
        members: [projectInfo.then(projectInfo => `serviceAccount:${projectInfo.projectNumber}-compute@developer.gserviceaccount.com`),],
        role: "roles/stackdriver.resourceMetadata.writer",
        project: projectId,
    }, { dependsOn: [api.iam] })
}
