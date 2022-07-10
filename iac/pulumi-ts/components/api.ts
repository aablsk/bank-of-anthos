import * as gcp from "@pulumi/gcp";
import { projectId } from "../config"

// define required apis
const enabledApis = [
    "container",
    "compute",
    "artifactregistry",
    "sourcerepo",
    "cloudbuild",
    "clouddeploy",
    "cloudresourcemanager"
].map(api => ({
    [api]: new gcp.projects.Service(`api-${api}`, {
        disableDependentServices: true,
        service: `${api}.googleapis.com`,
        project: projectId
    })
}))

export default Object.assign({}, ...enabledApis);

export type Apis = { string: gcp.projects.Service };