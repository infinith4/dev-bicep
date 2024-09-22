

az bicep install

az bicep upgrade


# Fetch the latest Bicep CLI binary
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
# Mark it as executable
chmod +x ./bicep
# Add bicep to your PATH (requires admin)
sudo mv ./bicep /usr/local/bin/bicep
# Verify you can now access the 'bicep' command
bicep --help
# Done!


azd login
azd init

azd up

azd deployment sub create --location <デプロイデータを格納する場所> --template-file <Bicepファイル名>

curl -L https://aka.ms/InstallAzureCli | bash

source ~/.bashrc

az version

az login

az group create --name rg-iac-bicep --location japaneast

az deployment group create --resource-group rg-iac-bicep --template-file main.bicep


az group list

az group delete --name rg-iac-bicep

az group list

az group show --name rg-iac-bicep



