// Parameters
//////////////////////////////////////////////////
@description('The id of the application gateway backend pool.')
param applicationGatewayBackendPoolId string

@description('The location for all resources.')
param location string

@description('The name of the virtual machine nic.')
param virtualMachineNicName string

@description('The name of the virtual machine public ip address.')
param virtualMachinePublicIpAddressName string

@description('The subnet id of the virtual machine subnet.')
param virtualMachineSubnetId string

// Resource - Public Ip Address - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachinePublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: virtualMachinePublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Virtual Machine NIC
//////////////////////////////////////////////////
resource virtualMachineNic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: virtualMachineNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualMachineSubnetId
          }
          publicIPAddress: {
            id: virtualMachinePublicIpAddress.id
          }
          applicationGatewayBackendAddressPools: [
            {
              id: applicationGatewayBackendPoolId
            }
          ]
        }
      }
    ]
  }
}
