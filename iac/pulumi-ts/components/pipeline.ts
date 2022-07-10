import type { Env } from "./env";

import * as pulumi from "@pulumi/pulumi";
import * as google_native from "@pulumi/google-native";
import api from "./api";
import { Bucket, BucketObject } from "@pulumi/google-native/storage/v1";
import { Trigger } from "@pulumi/google-native/cloudbuild/v1";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { DeliveryPipeline } from "@pulumi/google-native/clouddeploy/v1";
import { project, region } from "@pulumi/google-native/config";
import { registryName } from "../config";

export const createPipelines = (team: string, bucket: Bucket, targetNames: string[], envs: { string: Env }, cloudBuildServiceAccount: ServiceAccount) => {
    const cache = createCache(team, bucket);
    const integrationPipeline = createIntegrationPipeline(team, bucket, cloudBuildServiceAccount);
    const deliveryPipeline = createDeliveryPipeline(team, targetNames, envs);
    return { cache, integrationPipeline, deliveryPipeline };
}

const createCache = (team: string, bucket: Bucket) => new BucketObject(`cache-${team}`, {
    bucket: bucket.name,
    name: `${team}/cache`,
    source: new pulumi.asset.FileAsset("./resources/cache"),
});

const createIntegrationPipeline = (team: string, buildCacheBucket: Bucket, serviceAccount: ServiceAccount) => new Trigger(`cloud-build-${team}`, {
    eventType: google_native.cloudbuild.v1.TriggerEventType.Repo,
    filename: team !== "ledger" ? "cloudbuild.yaml" : "cloudbuild-mvnw.yaml",
    includedFiles: [
        `src/${team}/**`,
        "src/components/**",
    ],
    name: `${team}-ci`,
    projectId: project as string,
    triggerTemplate: {
        branchName: `^pulumi-ts$`,
        repoName: "bank-of-anthos",
        project: project,
    },
    substitutions: {
        _TEAM: team,
        _CACHE_URI: pulumi.interpolate`gs://${buildCacheBucket.name}/${team}/cache`,
        _CONTAINER_REGISTRY: `${region}-docker.pkg.dev/${project}/${registryName}`,
    },
    serviceAccount: serviceAccount.email,
    project: project,
    location: region,
}, {
    dependsOn: [api.cloudbuild, serviceAccount, buildCacheBucket],
});

const createDeliveryPipeline = (team: string, targetNames: string[], envs: { [key: string]: Env }) => {
    const targets = targetNames.map(name => envs[name]?.target);
    const stages = targetNames.map(name => ({ targetId: name, profiles: [name] }));
    const deliveryPipeline = new DeliveryPipeline(`cloud-deploy-${team}`, {
        deliveryPipelineId: team,
        description: `Delivery pipeline for ${team} team.`,
        serialPipeline: {
            stages
        },
        location: region
    }, {
        dependsOn: [
            api.clouddeploy,
            ...targets
        ],
    });

    return deliveryPipeline;
}