param hostingPlanName string
param location string = resourceGroup().location
param tags object = {}
param sku object = {}

param kind string = 'linux'


//https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.web/app-function/main.bicep
resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  kind: kind
  properties: {
    reserved: true
  }
  sku: sku
}

output id string = hostingPlan.id
output name string = hostingPlan.name
