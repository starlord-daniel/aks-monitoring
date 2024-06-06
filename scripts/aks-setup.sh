#!/bin/bash
set -euo pipefail

# This script creates an Azure Kubernetes Service (AKS) cluster and installs the Azure Machine Learning (AML) extension.
# Usage: ./aks-setup.sh <resource_group_name> <location> <aks_name>
#
# Parameters:
#   resource_group_name: The name of the resource group where the AKS cluster will be created.
#   location: The Azure region where the AKS cluster will be created.
#   aks_name: The name of the AKS cluster to be created.

create_resoruce_group() {
    local resource_group_name="${1}"
    local location="${2}"
    az group create --name "${resource_group_name}" --location "${location}"
}

create_aks_cluster() {

    local resource_group_name="${1}"
    local location="${2}"
    local aks_name="${3}"

    echo "Creating AKS cluster ${aks_name} in resource group ${resource_group_name}..."

    az aks create \
        --name "${aks_name}" \
        --resource-group "${resource_group_name}" \
        --location "${location}" \
        --generate-ssh-keys \
        --network-plugin azure \
        --network-plugin-mode overlay \
        --pod-cidr 192.168.0.0/16 \
        --enable-network-observability

    echo "AKS cluster created successfully"
}

install_aml_extension() {

    local resource_group_name="${1}"
    local aks_name="${2}"

    echo "Installing Azure Machine Learning extension on AKS cluster ${aks_name}..."

    az k8s-extension create \
        --name aml-aks-ext \
        --extension-type Microsoft.AzureML.Kubernetes \
        --cluster-type managedClusters \
        --cluster-name "${aks_name}" \
        --resource-group "${resource_group_name}" \
        --scope cluster \
        --config \
        enableTraining=True \
        enableInference=True \
        inferenceRouterServiceType=LoadBalancer \
        allowInsecureConnections=True \
        InferenceRouterHA=False

    echo "Azure Machine Learning extension installed successfully"

}

run_main() {

    local resource_group_name="${1}"
    local location="${2}"
    local aks_name="${3}"

    create_resoruce_group "${resource_group_name}" "${location}"
    create_aks_cluster "${resource_group_name}" "${location}" "${aks_name}"
    install_aml_extension "${resource_group_name}" "${aks_name}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
