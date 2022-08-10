// Parameters
//////////////////////////////////////////////////
@description('The password of the admin user.')
@secure()
param adminPassword string

@description('The name of the admin user.')
param adminUserName string

@description('The password of the certificate.')
@secure()
param certificatePassword string

@description('The name of the custom domain.')
param domainName string

@description('The name of the key Vault.')
param keyVaultName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the managed identity.')
param managedIdentityName string

@description('The name of the resource group.')
param resourceGroupName string

// Variables
//////////////////////////////////////////////////
var applicationGatewayName = 'appGw-e2esslvm-01'
var applicationGatewayPublicIpAddressName = 'pip-e2esslvm-applicationgateway'
var applicationGatewaySubnetName = 'snet-e2esslvm-applicationgateway'
var applicationGatewaySubnetPrefix = '10.0.0.0/24'
var networkSecurityGroupName = 'nsg-e2esslvm-virtualmachine'
var operatingSystemVersion = '2022-datacenter-smalldisk'
var scriptLocation = 'https://raw.githubusercontent.com/joshuawaddell/end-to-end-ssl-vm/main/scripts/installWebServer.ps1'
var scriptName = 'installWebServer.ps1'
var virtualMachineSubnetName = 'snet-e2esslvm-virtualmachine'
var virtualMachineSubnetPrefix = '10.0.1.0/24'
var virtualMachineName = 'vm-e2esslvm'
var virtualMachineNicName = 'nic-e2esslvm-virtualmachine'
var virtualMachineOsDiskName = 'disk-e2esslvm-virtualmachine'
var virtualMachinePublicIpAddressName = 'pip-e2esslvm-virtualmachine'
var virtualMachineSku = 'Standard_D2s_v5'
var virtualNetworkName = 'vnet-e2esslvm-01'
var virtualNetworkPrefix = '10.0.0.0/16'
var webApp1HostName = '${webApp1Name}.${domainName}'
var webApp1Name = 'webapp1'
var webApp2HostName = '${webApp2Name}.${domainName}'
var webApp2Name = 'webapp2'

// Existing Resources
//////////////////////////////////////////////////

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(resourceGroupName)
  name: keyVaultName
}

// Existing Resource - Managed Identity
//////////////////////////////////////////////////
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(resourceGroupName)
  name: managedIdentityName
}

// Modules
//////////////////////////////////////////////////

// Network Security Group Module
//////////////////////////////////////////////////
module networkSecurityGroupModule 'network_security_group.bicep' = {
  name: 'networkSecurityGroupDeployment'
  params: {
    location: location
    networkSecurityGroupName: networkSecurityGroupName
  }
}

// Virtual Network Module
//////////////////////////////////////////////////
module virtualNetworkModule 'virtual_network.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    location: location
    networkSecurityGroupId: networkSecurityGroupModule.outputs.networkSecurityGroupId
    virtualMachineSubnetName: virtualMachineSubnetName
    virtualMachineSubnetPrefix: virtualMachineSubnetPrefix
    virtualNetworkName: virtualNetworkName
    virtualNetworkPrefix: virtualNetworkPrefix
  }
}

// Virtual Machine Module
//////////////////////////////////////////////////
module virtualMachineModule 'virtual_machine.bicep' = {
  name: 'virtualMachineDeployment'
  params: {
    adminPassword: adminPassword
    adminUserName: adminUserName
    location: location
    operatingSystemVersion: operatingSystemVersion
    scriptLocation: scriptLocation
    scriptName: scriptName
    virtualMachineName: virtualMachineName
    virtualMachineNicName: virtualMachineNicName
    virtualMachineOsDiskName: virtualMachineOsDiskName
    virtualMachinePublicIpAddressName: virtualMachinePublicIpAddressName
    virtualMachineSku: virtualMachineSku
    virtualMachineSubnetId: virtualNetworkModule.outputs.virtualMachineSubnetId
    webApp1HostName: webApp1HostName
    webApp1Name: webApp1Name
    webApp2HostName: webApp2HostName
    webApp2Name: webApp2Name
  }
}

// Application Gateway Module
//////////////////////////////////////////////////
module applicationGatewayModule 'application_gateway.bicep' = {
  name: 'applicationGatewayDeployment'
  params: {
    managedIdentityId: managedIdentity.id
    applicationGatewayName: applicationGatewayName
    applicationGatewayPublicIpAddressName: applicationGatewayPublicIpAddressName
    applicationGatewaySubnetId: virtualNetworkModule.outputs.applicationGatewaySubnetId
    certificateData: keyVault.getSecret('certificate')
    certificatePassword: certificatePassword
    certificateName: domainName
    location: location
    webApp1HostName: webApp1HostName
    webApp2HostName: webApp2HostName
  }
}

// Module Virtual Machine NIC Update Module
//////////////////////////////////////////////////
module virtualMachineNicUpdateModule 'virtual_machine_nic_update.bicep' = {
  name: 'virtualMachineNicUpdateDeployment'
  params: {
    applicationGatewayBackendPoolId: applicationGatewayModule.outputs.backendPoolId
    location: location
    virtualMachineNicName: virtualMachineNicName
    virtualMachinePublicIpAddressName: virtualMachinePublicIpAddressName
    virtualMachineSubnetId: virtualNetworkModule.outputs.virtualMachineSubnetId
  }
}
