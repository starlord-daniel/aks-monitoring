#!/bin/bash
set -euo pipefail

# This script creates an Azure Machine Learning workspace and attaches an existing AKS cluster to it.
# Usage: ./aml-setup.sh <resource_group_name> <location> <aml_workspace_name> <aks_name>
#
# Parameters:
#   resource_group_name: The name of the resource group where the Azure Machine Learning workspace will be created.
#   location: The Azure region where the Azure Machine Learning workspace will be created.
#   aml_workspace_name: The name of the Azure Machine Learning workspace to be created.
#   aks_name: The name of the AKS cluster to attach to the Azure Machine Learning workspace.

create_aml_workspace() {

    local resource_group_name="${1}"
    local location="${2}"
    local aml_workspace_name="${3}"

    echo "Creating Azure Machine Learning workspace ${aml_workspace_name} in resource group ${resource_group_name}..."

    az ml workspace create \
        --name "${aml_workspace_name}" \
        --resource-group "${resource_group_name}" \
        --location "${location}"

    echo "Azure Machine Learning workspace created successfully"
}

attach_aks_to_aml() {

    local rg_name="${1}"
    local aml_workspace_name="${2}"
    local aks_name="${3}"

    echo "Retrieving subscription ID..."

    local subscription_id
    subscription_id=$(az account show --query id --output tsv)

    echo "Attaching AKS cluster ${aks_name} to Azure Machine Learning workspace ${aml_workspace_name}..."

    az ml compute attach \
        --resource-group "${rg_name}" \
        --workspace-name "${aml_workspace_name}" \
        --type Kubernetes \
        --name "aks-compute" \
        --resource-id "/subscriptions/${subscription_id}/resourceGroups/$rg_name/providers/Microsoft.ContainerService/managedclusters/${aks_name}" \
        --identity-type SystemAssigned \
        --namespace azureml \
        --no-wait
}

run_main() {

    local resource_group_name="${1}"
    local location="${2}"
    local aml_workspace_name="${3}"
    local aks_name="${4}"

    create_aml_workspace "${resource_group_name}" "${location}" "${aml_workspace_name}"
    attach_aks_to_aml "${resource_group_name}" "${aml_workspace_name}" "${aks_name}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
