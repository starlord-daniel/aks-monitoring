#!/bin/bash
set -euo pipefail

# This script creates an Azure Monitor and Grafana resources and links them to an existing AKS cluster.
# Usage: ./monitoring-setup.sh <resource_group_name> <location> <aks_name> <az_monitor_name> <grafana_name>
#
# Parameters:
#   resource_group_name: The name of the resource group where the Azure Monitor and Grafana resources will be created.
#   location: The Azure region where the Azure Monitor and Grafana resources will be created.
#   aks_name: The name of the AKS cluster to link the Azure Monitor and Grafana resources to.
#   az_monitor_name: The name of the Azure Monitor resource to be created.
#   grafana_name: The name of the Grafana resource to be created.

AZURE_MONITOR_ID=""
GRAFANA_ID=""

create_azure_monitor() {

    local rg_name="${1}"
    local location="${2}"
    local az_monitor_name="${3}"

    az resource create \
        --resource-group "${rg_name}" \
        --namespace microsoft.monitor \
        --resource-type accounts \
        --name "${az_monitor_name}" \
        --location "${location}" \
        --properties '{}'

    AZURE_MONITOR_ID=$(az resource show \
        --resource-group "${rg_name}" \
        --name "${az_monitor_name}" \
        --resource-type "Microsoft.Monitor/accounts" \
        --query id \
        --output tsv)
}

create_grafana() {

    local rg_name="${1}"
    local grafana_name="${2}"

    az grafana create \
        --name "${grafana_name}" \
        --resource-group "${rg_name}"

    GRAFANA_ID=$(az grafana show \
        --name "${grafana_name}" \
        --resource-group "${rg_name}" \
        --query id \
        --output tsv)
}

link_monitor_and_grafana_to_aks() {

    local rg_name="${1}"
    local aks_name="${2}"

    az aks update \
        --name "${aks_name}" \
        --resource-group "${rg_name}" \
        --enable-azure-monitor-metrics \
        --azure-monitor-workspace-resource-id "${AZURE_MONITOR_ID}" \
        --grafana-resource-id "${GRAFANA_ID}"
}

run_main() {

    local resource_group_name="${1}"
    local location="${2}"
    local aks_name="${3}"
    local az_monitor_name="${4}"
    local grafana_name="${5}"

    echo "Creating Azure Monitor..."
    create_azure_monitor "${resource_group_name}" "${location}" "${az_monitor_name}"

    echo "Creating Grafana..."
    create_grafana "${resource_group_name}" "${grafana_name}"

    echo "Azure Monitor ID: ${AZURE_MONITOR_ID}"
    echo "Grafana ID: ${GRAFANA_ID}"

    echo "Linking Azure Monitor and Grafana to AKS..."
    link_monitor_and_grafana_to_aks "${resource_group_name}" "${aks_name}"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_main "$@"
fi
