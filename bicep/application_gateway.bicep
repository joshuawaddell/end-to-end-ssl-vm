// Parameters
//////////////////////////////////////////////////
@description('The resource id of the managed identity.')
param managedIdentityId string

@description('The name of the application gateway.')
param applicationGatewayName string

@description('The name of the application gateway public ip address.')
param applicationGatewayPublicIpAddressName string

@description('The resource id of the application gateway subnet')
param applicationGatewaySubnetId string

@description('The data of the ssl certificate (stored in keyvault.)')
@secure()
param certificateData string

@description('The password of the ssl certificate (stored in keyvault.)')
@secure()
param certificatePassword string

@description('The name of the ssl certificate (stored in keyvault).')
param certificateName string

@description('The location for all resources.')
param location string

@description('The host name of web application 1.')
param webApp1HostName string

@description('The host name of web application 2.')
param webApp2HostName string

// Resource - Public Ip Address - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: applicationGatewayPublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Application Gateway
//////////////////////////////////////////////////
resource applicationGateway 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    enableHttp2: false
    sslCertificates: [
      {
        name: certificateName
        properties: {
          data: certificateData
          password: certificatePassword
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIPConfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIpConfiguration'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [  
      {
        name: 'httpSetting-${webApp1HostName}'
        properties: {
          cookieBasedAffinity: 'Disabled'                    
          requestTimeout: 20
          hostName: webApp1HostName
          port: 443
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'healthProbe-${webApp1HostName}')
          }
          protocol: 'Https'
        }
      }
      {
        name: 'httpSetting-${webApp2HostName}'
        properties: {
          cookieBasedAffinity: 'Disabled'                    
          requestTimeout: 20
          hostName: webApp2HostName
          port: 443
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'healthProbe-${webApp2HostName}')
          }
          protocol: 'Https'
        }
      }
    ]    
    httpListeners: [
      {
        name: 'listener-${webApp1HostName}-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: webApp1HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${webApp1HostName}-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, certificateName)
          }
          hostName: webApp1HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${webApp2HostName}-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: webApp2HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${webApp2HostName}-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, certificateName)
          }
          hostName: webApp2HostName
          requireServerNameIndication: false
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'redirectConfiguration-${webApp1HostName}'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp1HostName}-https')
          }
        }
      }
      {
        name: 'redirectConfiguration-${webApp2HostName}'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp2HostName}-https')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule-${webApp1HostName}'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp1HostName}')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendpool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSetting-${webApp1HostName}')
          }
        }
      }
      {
        name: 'routingRule-${webApp1HostName}-redirection'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp1HostName}-http')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectConfiguration-${webApp1HostName}')
          }
        }
      }
      {
        name: 'routingRule-${webApp2HostName}'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp2HostName}')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendpool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSetting-${webApp2HostName}')
          }
        }
      }
      {
        name: 'routingRule-${webApp2HostName}-redirection'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${webApp2HostName}-http')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectConfiguration-${webApp2HostName}')
          }
        }
      }
    ]
    probes: [      
      {
        name: 'healthProbe-${webApp1HostName}'
        properties: {
          interval: 30
          match: {
            statusCodes: [
              '200-399'
            ]
          }
          path: '/'
          pickHostNameFromBackendHttpSettings: true
          protocol: 'Https'
          timeout: 30
          unhealthyThreshold: 3          
        }
      }
      {
        name: 'healthProbe-${webApp2HostName}'
        properties: {
          interval: 30
          match: {
            statusCodes: [
              '200-399'
            ]
          }
          path: '/'
          pickHostNameFromBackendHttpSettings: true
          protocol: 'Https'
          timeout: 30
          unhealthyThreshold: 3          
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
}

// Outputs
//////////////////////////////////////////////////
output backendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool')
