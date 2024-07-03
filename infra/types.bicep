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
