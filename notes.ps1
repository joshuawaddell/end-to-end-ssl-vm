# Parameters
param(
  [String] $location='eastus',
  [String] $resourceGroupName='rg-e2esslvm',
  [String] $keyVaultName='kv-e2esslvm',
  [String] $managedIdentityName='id-e2esslvm-applicationgateway',
  [String] $pfxCertificatePath='C:\Users\joshu\downloads\wildcard.pfx',
  [SecureString] $certificatePassword=$(Read-Host -prompt "Enter the password for the pfx certificate" -AsSecureString),
  [String] $base64Path='C:\Users\joshu\downloads\base64.txt',
  [SecureString] $adminPassword=$(Read-Host -prompt "Enter the password for Azure Resources" -AsSecureString),
  [String] $adminUserName='serveradmin',
  [String] $domainName='joshuawaddell.cloud'
)

# Variables
$keyVaultSecretName='certificate'

# Create Resource Group
az group create -n $resourceGroupName -l $location

# Create Key Vault
az keyvault create -g $resourceGroupName -n $KeyVaultName --sku standard --enabled-for-deployment true --enabled-for-template-deployment true --enabled-for-disk-encryption true --enable-purge-protection true --retention-days 7

# Convert Certificate Password into Plain Text
$certificatePasswordPlainText = ConvertFrom-SecureString -SecureString $certificatePassword -AsPlainText

# Convert Certificate from PFX to Base64
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($pfxCertificatePath)) | Out-File $base64Path | Out-Null

# Create a Key Vault Secret
az keyvault secret set -n $keyVaultSecretName --vault-name $keyVaultName --file $base64Path

# Create Managed Identity
az identity create -g $resourceGroupName -n $managedIdentityName

# Assign Managed Identity to Key Vault Access Policy
$managedIdentitySpnId = az identity show -g $resourceGroupName -n $managedIdentityName --query principalId
az keyvault set-policy -g $resourceGroupName -n $keyVaultName --object-id $managedIdentitySpnId --secret-permissions get

# Convert Admin Password into Plain Text
$adminPasswordPlainText = ConvertFrom-SecureString -SecureString $adminPassword -AsPlainText

# Deploy Azure Resources
az deployment group create -g $resourceGroupName -f bicep\main.bicep --parameters adminPassword=$adminPasswordPlainText adminUserName=$adminUserName certificatePassword=$certificatePasswordPlainText domainName=$domainName keyVaultName=$keyVaultName location=$location managedIdentityName=$managedIdentityName resourceGroupName=$resourceGroupName
