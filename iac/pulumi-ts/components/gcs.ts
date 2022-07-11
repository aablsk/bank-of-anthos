import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { Bucket } from "@pulumi/google-native/storage/v1";
import { BucketIAMBinding } from "@pulumi/gcp/storage";
import { getProject } from "@pulumi/google-native/cloudresourcemanager/v1";
import { project, region } from "@pulumi/google-native/config";
import { interpolate } from "@pulumi/pulumi";

export const createBucket = (name: string, serviceAccounts: ServiceAccount[]) => {
    const bucket = new Bucket(name, {
        name: getProject({project: project}).then(projectInfo => `${name}-${projectInfo.projectNumber}`),
        iamConfiguration: {
            uniformBucketLevelAccess: {
                enabled: true
            }
        },
        location: region,
    })
    new BucketIAMBinding(name, {
        bucket: bucket.name,
        members: serviceAccounts.map(serviceAccount => interpolate`serviceAccount:${serviceAccount.email}`),
        role: 'roles/storage.admin'
    }, {
        dependsOn: [bucket, ...serviceAccounts]
    })
    return bucket;
};