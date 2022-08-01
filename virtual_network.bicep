// Parameters
//////////////////////////////////////////////////
@description('The name of the application gateway subnet.')
param applicationGatewaySubnetName string

@description('The address prefix of the application gateway subnet.')
param applicationGatewaySubnetPrefix string

@description('The location of all resources.')
param location string

@description('The resource id of the network security gorup.')
param networkSecurityGroupId string

@description('The name of the virtual machine subnet.')
param virtualMachineSubnetName string

@description('The address prefix of the virtual machine subnet.')
param virtualMachineSubnetPrefix string

@description('The name of the virtual network.')
param virtualNetworkName string

@description('The address prefix of the virtual network.')
param virtualNetworkPrefix string

// Resource - Virtual Network
//////////////////////////////////////////////////
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetPrefix
        }
      }
      {
        name: virtualMachineSubnetName
        properties: {
          addressPrefix: virtualMachineSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }  
    ]
  }
  resource applicationGatewaySubnet 'subnets' existing = {
    name: applicationGatewaySubnetName
  }
  resource virtualMachineSubnet 'subnets' existing = {
    name: virtualMachineSubnetName
  }
}

// Outputs
//////////////////////////////////////////////////
output virtualNetworkId string = virtualNetwork.id
output applicationGatewaySubnetId string = virtualNetwork::applicationGatewaySubnet.id
output virtualMachineSubnetId string = virtualNetwork::virtualMachineSubnet.id
