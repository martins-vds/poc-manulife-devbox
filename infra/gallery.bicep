param galleryName string
param devCenterName string
param devCenterPrincipalId string
param imageBuilderPrincipalId string
param imageBuilderRoleId string
param location string

var contributorRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
)

resource gallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: galleryName
  location: location
}

resource devCenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' existing = {
  name: devCenterName
}

resource galleryContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, devCenterPrincipalId, contributorRoleDefinitionId)
  scope: gallery
  properties: {
    principalId: devCenterPrincipalId
    roleDefinitionId: contributorRoleDefinitionId
  }
}

resource galleryImageBuilderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, imageBuilderPrincipalId, imageBuilderRoleId)
  scope: gallery
  properties: {
    principalId: imageBuilderPrincipalId
    roleDefinitionId: imageBuilderRoleId
  }
}

resource devCenterExternalGallery 'Microsoft.DevCenter/devcenters/galleries@2024-05-01-preview' = {
  parent: devCenter
  name: 'External'
  properties: {
    galleryResourceId: gallery.id
  }

  dependsOn: [
    galleryContributorRoleAssignment
  ]
}

output galleryName string = gallery.name
