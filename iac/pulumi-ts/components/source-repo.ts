import { ServiceAccount } from "@pulumi/google-native/iam/v1";
import { project } from "@pulumi/google-native/config";
import { registryName } from "../config";
import { Repo } from "@pulumi/google-native/sourcerepo/v1";
import api from "./api";
import { RepositoryIamBinding } from "@pulumi/gcp/sourcerepo";
import { interpolate } from "@pulumi/pulumi";

export const createSourceRepo = (serviceAccount: ServiceAccount) => {
    const repo = new Repo("source-mirror", { name: `projects/${project}/repos/${registryName}` }, {
        dependsOn: [
            api.sourcerepo,
        ],
    });

    new RepositoryIamBinding("source-mirror", {
        repository: repo.name,
        members: [interpolate`serviceAccount:${serviceAccount.email}`],
        role: 'roles/source.reader'
    }, {
        dependsOn: [repo, serviceAccount]
    })

    return repo;
}