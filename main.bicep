// Main.bicep

// Parameters
param containerRegistryName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param location string

@secure()
param dockerRegistryServerPassword string
param dockerRegistryServerUrl string
param dockerRegistryServerUsername string

// Azure Container Registry module
module acr './modules/container-registry/registry/main.bicep' = {
  name: containerRegistryName
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

// Azure Service Plan for Linux module
module servicePlan './modules/web/serverfarm/main.bicep' = {
  name: appServicePlanName
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

// Azure Web App for Linux containers module
module webApp './modules/web/site/main.bicep' = {
  name: webAppName
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: servicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: dockerRegistryServerUrl
      DOCKER_REGISTRY_SERVER_USERNAME: dockerRegistryServerUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: dockerRegistryServerPassword
    }
  }
}
