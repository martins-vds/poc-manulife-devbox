param imageBuilderName string
param location string

module imageBuilderRole 'rbac_role.bicep' = {
  name: '${deployment().name}-imageBuilderRole'
  params:{
    roleName: 'Image Creation Role'
    roleDescription: 'Azure Image Builder access to create resources for the image build'
  }
}

resource imageBuilderIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: imageBuilderName
  location: location
}

output id string = imageBuilderIdentity.id
output principalId string = imageBuilderIdentity.properties.principalId
output roleId string = imageBuilderRole.outputs.roleDefinitionID
