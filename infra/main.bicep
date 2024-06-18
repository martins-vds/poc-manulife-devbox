param location string = resourceGroup().location

var uniqueness = uniqueString(resourceGroup().id)
var galleryName = 'gallery${uniqueness}'
var vnetName = 'vnet${uniqueness}'
var devCenterName = 'devcenter${uniqueness}'

module network 'network.bicep' = {
  name: '${deployment().name}-network'
  params: {
    location: location
    vnetName: vnetName    
  }
}

module devcenter 'devcenter.bicep' = {
  name: '${deployment().name}-devcenter'
  params: {
    devCenterName: devCenterName
    location: location    
    vnetResourceGroupName: network.outputs.resourceGroupName
    subnetId: network.outputs.defaultSubnetId
  }
}

module gallery 'gallery.bicep' = {
  name: '${deployment().name}-gallery'
  params: {
    galleryName: galleryName
    location: location
    devCenterName: devCenterName
    devCenterPrincipalId: devcenter.outputs.principalId
  }
}
