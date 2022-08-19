/* output "gke" {
  value = module.gke
} */

output "network" {
  value = module.network
}

output "network_name" {
    value = module.network.network_name
}

output "subnetwork" {
    value = local.subnet_names[index(module.network.subnets_names, local.subnet_name)]
}

output "ip_range_pods" {
    value = local.pods_range_name
}

output "ip_range_services" {
    value = local.svc_range_name
}