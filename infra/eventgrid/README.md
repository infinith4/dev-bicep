cd eventgrid
az deployment group create \
  --name rg-iac-bicep-dev-eventgrid-deploy \
  --resource-group rg-iac-bicep \
  --mode Incremental \
  --confirm-with-what-if \
  --template-file main.bicep \
  --parameters ./main.parameters.dev.json