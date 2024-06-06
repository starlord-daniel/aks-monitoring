# AKS multi-purpose Monitoring

This repository contains scripts and documentation on how to configure monitoring for an AKS cluster. The monitoring solution is based on Prometheus and Grafana. The monitoring solution is multi-purpose and can be used for monitoring the AKS cluster, the applications running on the AKS cluster, and the underlying infrastructure.

To demonstrate monitoring, the AKS cluster is connected to an Azure Machine Learning (AML) workspace.

## Prerequisites

- [Register the Kubernetes Resource Provider](https://learn.microsoft.com/azure/aks/dapr?view=azureml-api-2&tabs=cli#register-the-kubernetesconfiguration-resource-provider)
- [Setup Network Observability for AKS](https://learn.microsoft.com/azure/aks/network-observability-managed-cli?tabs=non-cilium)
  - IMPORTANT: Do not create any services yet. Use the provided scripts for that

## Steps

- Create and fill out the `.env` file with the desired values
- Run `az login` to login to your Azure account
- Run the `make aks` script to deploy a resource group, an AKS cluster and install the AML extension
- Run the `make monitoring` script to deploy the monitoring solution
- Run the `make aml` script to deploy an AML workspace and attach the AKS cluster to the workspace
- Run the `make finalize` script to connect to the cluster and finalize the monitoring solution

## References

- [Setup Monitoring for AKS](https://learn.microsoft.com/azure/aks/network-observability-managed-cli?tabs=non-cilium)
- [AML AKS Setup](https://learn.microsoft.com/azure/machine-learning/how-to-attach-kubernetes-anywhere?view=azureml-api-2#kubernetescompute-and-legacy-akscompute)
- [Deploy Kubernetes extension](https://learn.microsoft.com/azure/machine-learning/how-to-deploy-kubernetes-extension?view=azureml-api-2&tabs=deploy-extension-with-cli)
- [Use AKS as AML compute](https://learn.microsoft.com/azure/machine-learning/how-to-attach-kubernetes-to-workspace?view=azureml-api-2&tabs=cli)
