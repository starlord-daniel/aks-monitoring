
# Create the monitoring infrastructure based on the monitoring script

all: aks monitoring aml finalize

# Source .env file
include .env

# Variables
RG_NAME=${PREFIX}-${RESOURCE_GROUP_NAME}
LOC=${LOCATION}
AKS_NAME=${PREFIX}-${AKS_CLUSTER_NAME}
AZ_MONITOR=${PREFIX}-${AZ_MONITOR_NAME}
GRAFANA=${PREFIX}-${GRAFANA_NAME}
AML_WORKSPACE=${PREFIX}-${AML_WORKSPACE_NAME}

PHONY: aks
aks:
	@echo "Creating AKS in ${LOC} with name ${AKS_NAME} in resource group ${RG_NAME}"
	@bash ./scripts/aks-setup.sh ${RG_NAME} ${LOC} ${AKS_NAME}
	@echo "AKS created and configured successfully!"

PHONY: monitoring
monitoring:
	@echo "Creating monitoring infrastructure"
	@bash ./scripts/monitoring-setup.sh ${RG_NAME} ${LOCATION} ${AKS_NAME} ${AZ_MONITOR} ${GRAFANA}

PHONY: aml
aml:
	@echo "Creating Azure Machine Learning workspace"
	@bash ./scripts/aml-setup.sh ${RG_NAME} ${LOCATION} ${AML_WORKSPACE} ${AKS_NAME}

PHONY: finalize
finalize:
	@echo "Finalizing the setup"
	az aks get-credentials --name ${AKS_NAME} --resource-group ${RG_NAME} --overwrite-existing
