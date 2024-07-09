# Fetch dev center object using azure cli
# Usage: ./get-devcenter.sh <resource-group> <devcenter-name>
# Example: ./get-devcenter.sh my-rg my-devcenter

# Check if azure cli is installed
if ! command -v az &> /dev/null
then
    echo "Azure CLI could not be found. Please install it before running this script."
    exit
fi

# Check if resource group and dev center name are provided
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Please provide resource group and dev center name."
    exit
fi

# Fetch dev center object with provided resource group and dev center name
$devCenter=$(az resource show --resource-group $1 --name $2 --resource-type Microsoft.DevCenter/DevCenters --api-version 2018-01-01)
