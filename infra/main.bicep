param location string = resourceGroup().location

var uniqueness = uniqueString(resourceGroup().id)
var galleryName = 'gallery${uniqueness}'
var vnetName = 'vnet${uniqueness}'
var devCenterName = 'devcenter${uniqueness}'
var imageBuilderName = 'imagebuilder${uniqueness}'

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

module imageBuilder 'image-builder.bicep' = {
  name: '${deployment().name}-imageBuilder'
  params: {
    imageBuilderName: imageBuilderName
    location: location
  }
}

module gallery 'gallery.bicep' = {
  name: '${deployment().name}-gallery'
  params: {
    galleryName: galleryName
    location: location
    devCenterName: devCenterName
    devCenterPrincipalId: devcenter.outputs.principalId
    imageBuilderPrincipalId: imageBuilder.outputs.principalId
    imageBuilderRoleId: imageBuilder.outputs.roleId
  }
}

output galleryName string = gallery.outputs.galleryName
output imageBuilderPrincipalId string = imageBuilder.outputs.principalId
