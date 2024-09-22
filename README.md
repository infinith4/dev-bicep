

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
azd deployment group create --resource-group rg-iac-bicep --location japaneast --template-file main.bicep

azd deployment sub create --location <デプロイデータを格納する場所> --template-file <Bicepファイル名>

