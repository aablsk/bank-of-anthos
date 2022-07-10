import { Config } from "@pulumi/pulumi"

const gcpConfig = new Config("google-native")
export const projectId = gcpConfig.require("project");
export const region = gcpConfig.require("region");

const config = new Config();
export const registryName = config.require("registryName")
export const projectOwner = config.require("projectOwner");