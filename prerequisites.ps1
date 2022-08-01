# Parameters
$base64Path = 'PATH TO BASE64 CERTIFICATE'
$keyVaultName = 'NAME OF KEY VAULT'
$keyVaultSecretName = 'NAME OF KEY VAULT SECRET'
$location = 'AZURE REGION'
$managedIdentityName = 'NAME OF MANAGED IDENTITY'
$pfxPath = 'PATH TO PFX CERTIFICATE'
$resourceGroupName = 'NAME OF RESOURCE GROUP'

# Create Resource Group
az group create -n $resourceGroupName -l $location

# Create Key Vault
az keyvault create -g $resourceGroupName -n $KeyVaultName --sku standard --enabled-for-deployment true --enabled-for-template-deployment true --enabled-for-disk-encryption true --enable-soft-delete true --enable-purge-protection true --retention-days 7

# Convert Certificate from PFX to Base64
// TODO: $base64 = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($pfxPath)) | Out-File $base64Path

# Create a Key Vault Secret
az keyvault secret set -n $keyVaultSecretName --vault-name $keyVaultName --value $base64

# Create Managed Identity

az identity create -g $resourceGroupName -n $managedIdentityName

# Assign Managed Identity to Key Vault Access Policy
$managedIdentitySpnId = az identity show -g $resourceGroupName -n $managedIdentityName --query principalId
az keyvault set-policy -g $resourceGroupName -n $keyVaultName --object-id $managedIdentitySpnId --secret-permissions get
