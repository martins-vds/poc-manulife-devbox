# POC - Microsoft DevBox

## Description

This project is a proof of concept (POC) to demonstrate the use of Microsoft DevBox.

## Notes

- It is possible that the deployment fails due to Network Connections quota limitations. If this happens, submit a request to increase the quota.

## Instructions

1. Clone this repository.
2. Using Visual Studio Code, open this repository as a Dev Container.
3. Run the following command to deploy the resources:

```bash
az login
az group create --name <resource-group-name> --location <location>
./scripts/deploy.sh <resource-group-name>
```
