param vnetName string
param location string = resourceGroup().location

var defaultSubnetName = 'default'

resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: '${vnetName}-${defaultSubnetName}-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]      
    }
    subnets: [
      {
        name: defaultSubnetName
        properties: {
          addressPrefixes: [
            '10.1.0.0/24'
          ]
          networkSecurityGroup: {
            id: defaultNsg.id
          }
        }
      }
    ]
  }

  resource defaultSubnet 'subnets' existing = {
    name: defaultSubnetName   
  }
}

output resourceGroupName string = resourceGroup().name
output defaultSubnetId string = vnet::defaultSubnet.id
