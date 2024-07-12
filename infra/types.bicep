@export()
type devCenterCatalog = {
  name: string
  gitHub: {
    uri: string
    branch: string
    path: string
  }
}

@export()
type devCenterCatalogArray = devCenterCatalog[]

@export()
type devBoxEnvironmentType = {
  name: string
  subscriptionId: string
  roles: object
}

@export()
type devCenterEnvironmentTypeArray = devBoxEnvironmentType[]

@export()
type devCenterProject = {
  devBoxDefinitionName: string
  projectName: string
  catalogs: devCenterCatalogArray
  environmentTypes: devCenterEnvironmentTypeArray
  permissions: {
    devBoxUsers: string[]
    devBoxAdmins: string[]
  }
}
