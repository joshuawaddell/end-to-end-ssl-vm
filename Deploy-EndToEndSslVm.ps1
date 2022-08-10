# Parameters
param(
    [String] $location=$(Read-Host -prompt "Enter the Azure Region for deployment. (Example: eastus)"),
    [String] $resourceGroupName=$(Read-Host -prompt "Enter the name of the Azure Resource Group for deployment. (Example: rg-end2endsslvm)"),
    [String] $keyVaultName=$(Read-Host -prompt "Enter the name of the Azure Key Vault. (Example: kv-end2endsslvm)"),
    [String] $managedIdentityName=$(Read-Host -prompt "Enter the name of the Azure Managed Identity. (Example: id-end2endsslvm)"),
    [String] $pfxCertificatePath=$(Read-Host -prompt "Enter the path to the PFX Certificate. (Example: 'C:\certificates\wildcard.pfx')"),
    [SecureString] $certificatePassword=$(Read-Host -prompt "Enter the password to the PFX Certificate" -AsSecureString),
    [String] $base64Path=$(Read-Host -prompt "Enter the path to the Base64 Certificate export. (Example: 'C:\certificates\wildcard.txt')"),
    [SecureString] $adminPassword=$(Read-Host -prompt "Enter he password to the Virtual Machine Administrator user." -AsSecureString),
    [String] $adminUserName=$(Read-Host -prompt "Enter the name of the Administrator user. (Example: resourceadmin)"),
    [String] $domainName=$(Read-Host -prompt "Enter the name of the Cusotm Domain. (Example: mydomain.com)")
    )

# Variables
$keyVaultSecretName='certificate'

# Create Resource Group
az group create -n $resourceGroupName -l $location

# Create Key Vault
az keyvault create -g $resourceGroupName -n $KeyVaultName --sku standard --enabled-for-deployment true --enabled-for-template-deployment true --enabled-for-disk-encryption true --enable-purge-protection true --retention-days 7

# Convert Secure Password into Plain Text
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

# Deploy Azure Resources
az deployment group create -g $resourceGroupName -f bicep\main.bicep --parameters adminPassword=$adminPassword adminUserName=$adminUserName certificatePassword=$certificatePasswordPlainText domainName=$domainName keyVaultName=$keyVaultName location=$location managedIdentityName=$managedIdentityName resourceGroupName=$resourceGroupName
