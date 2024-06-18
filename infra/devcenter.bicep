param devCenterName string
param location string
param vnetResourceGroupName string
param subnetId string

var deployVnet = true

resource devCenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Disabled'
    }
  }

  resource defaultGallery 'galleries' existing = {
    name: 'Default'
  }
}

resource devCenterDevBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-05-01-preview' = {
  parent: devCenter
  name: 'vs-2022-enterprise-win-11-enterprise'
  location: location
  properties: {
    imageReference: {
      id: '${devCenter::defaultGallery.id}/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
    sku: {
      name: 'general_i_8c32gb256ssd_v2'
    }
    hibernateSupport: 'Enabled'
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-05-01-preview' = if (deployVnet) {  
  name: 'networkConnection'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    networkingResourceGroupName: vnetResourceGroupName
    subnetId: subnetId
  }
}

output principalId string = devCenter.identity.principalId
