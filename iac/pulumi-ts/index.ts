import { region, project } from "@pulumi/google-native/config";

import { createEnv } from "./components/env";
import { createPipelines } from "./components/pipeline";
import { createArtifactRegistry } from "./components/artifact-registry";
import { createBucket } from "./components/gcs";
import { createSourceRepo } from "./components/source-repo";
import { setupIam } from "./components/iam-setup";
import { registryName } from "./config";

const { gkeServiceAccount, cloudDeployServiceAccount, cloudBuildServiceAccount } = setupIam();

const envNames = [
    "development",
    "staging",
    "production",
]
const teams = [
    "accounts",
    "frontend",
    "ledger",
];

// create shared resources (GCS bucket for caching, source repo for code mirroring, adds rolebindings)
const artifactRegistry = createArtifactRegistry(gkeServiceAccount, cloudBuildServiceAccount);
const sourceMirror = createSourceRepo(cloudBuildServiceAccount);
const cacheBucket = createBucket("build-cache", cloudBuildServiceAccount);
const releaseStagingBucket = createBucket("release-source-staging", cloudDeployServiceAccount);

// create environments (gke, network, cloud deploy target)
const envs = Object.assign({}, ...(envNames.map(name => ({ [name]: createEnv(name, gkeServiceAccount, cloudDeployServiceAccount) }))));

// create ci & cd pipeline per team
teams.map(team => ({ [team]: createPipelines(team, cacheBucket, ["staging", "production"], envs, cloudBuildServiceAccount) }));

// output follow-up commands
console.log("Finish setup with commands below:");
const finalizingCommands = envNames.reduce((prev, curr) => prev + `gcloud container clusters get-credentials ${curr} --region ${region} --project=${project} && kubectl annotate serviceaccount default --namespace=default iam.gke.io/gcp-service-account=gke-workload@${project}.iam.gserviceaccount.com && \\\n`, "") +
    `gcloud auth configure-docker europe-west1-docker.pkg.dev && skaffold config set default-repo ${region}-docker.pkg.dev/${project}/${registryName} && \\\n` +
    `git remote add ${project} https://source.developers.google.com/p/${project}/r/${registryName} && git push --all ${project}`;
console.log(finalizingCommands);
