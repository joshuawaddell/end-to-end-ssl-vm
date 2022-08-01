// Parameters
//////////////////////////////////////////////////
@description('The location for all resources.')
param location string

@description('The name of the network security gorup.')
param networkSecurityGroupName string

// Resource - Network Security Group
//////////////////////////////////////////////////
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP_Inbound'
        properties: {
          description: 'Allow RDP Access'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

// Outputs
//////////////////////////////////////////////////
output networkSecurityGroupId string = networkSecurityGroup.id
