import api from "./api";
import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { Network } from "@pulumi/google-native/compute/v1";
import { Target } from "@pulumi/google-native/clouddeploy/v1";
import { Bucket } from "@pulumi/google-native/storage/v1";
import { region, project } from "@pulumi/google-native/config";
import { interpolate } from "@pulumi/pulumi";
import { projectId } from "../config";
import { BucketIAMBinding } from "@pulumi/gcp/storage";
import { Cluster } from "@pulumi/google-native/container/v1";

export type Env = {
    network: Network,
    cluster: Cluster,
    target: Target,
}

export const createEnv = (name: string, gkeServiceAccount: ServiceAccount, cloudDeployServiceAccount: ServiceAccount) => {
    const network = createNetwork(name);
    const cluster = createCluster(name, network, gkeServiceAccount);
    const target = createTarget(name, cluster, cloudDeployServiceAccount);
    return { network, cluster, target};
}

const createNetwork = (name: string) => new Network(name, {
    name,
    autoCreateSubnetworks: true,
}, {
    dependsOn: [api.compute],
});

const createCluster = (name: string, network: Network, serviceAccount: ServiceAccount) => new Cluster(name, {
    name,
    autopilot: {
        enabled: true,
    },
    network: name,
    location: region,
    project: projectId,
}, {
    dependsOn: [
        api.compute,
        api.container,
        network,
    ],
});

const createTarget = (name: string, cluster: Cluster, serviceAccount: ServiceAccount) => {
    const artifactBucket = new Bucket(`cloud-deploy-exec-${name}`, {
        location: region,
        iamConfiguration: {
            publicAccessPrevention: 'enforced',
            uniformBucketLevelAccess: {
                enabled: true,
            },
        }
    })
    const artifactBucketIamBinding = new BucketIAMBinding(`cloud-deploy-exec-${name}`, {
        bucket: artifactBucket.name,
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: 'roles/storage.objectAdmin',
    }, {
        dependsOn: [artifactBucket, serviceAccount]
    })

    return new Target(name, {
        targetId: name,
        gke: {
            cluster: `projects/${project}/locations/${region}/clusters/${name}`,
        },
        executionConfigs: [
            {
                usages: ['DEPLOY', 'RENDER'],
                serviceAccount: serviceAccount.email,
                artifactStorage: interpolate`gs://${artifactBucket.name}`,
            }
        ]
    }, {
        dependsOn: [cluster, api.clouddeploy, artifactBucket, artifactBucketIamBinding, serviceAccount],
    })
};