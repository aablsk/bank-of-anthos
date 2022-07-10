import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { Bucket } from "@pulumi/google-native/storage/v1";
import { BucketIAMBinding } from "@pulumi/gcp/storage";
import { getProject } from "@pulumi/google-native/cloudresourcemanager/v1";
import { project } from "@pulumi/google-native/config";
import { interpolate } from "@pulumi/pulumi";

export const createBucket = (name: string, serviceAccount: ServiceAccount) => {
    const bucket = new Bucket(name, {
        name: getProject({project: project}).then(projectInfo => `${name}-${projectInfo.projectNumber}`),
        iamConfiguration: {
            uniformBucketLevelAccess: {
                enabled: true
            }
        }
    })
    new BucketIAMBinding(name, {
        bucket: bucket.name,
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: 'roles/storage.objectAdmin'
    }, {
        dependsOn: [bucket, serviceAccount]
    })
    return bucket;
};