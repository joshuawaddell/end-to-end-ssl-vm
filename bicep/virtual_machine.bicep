// Parameters
//////////////////////////////////////////////////
@description('The password of the administrator account.')
@secure()
param adminPassword string

@description('The user name of the administrator account.')
param adminUserName string

@description('The location for all resources.')
param location string

@description('The version of the operating system.')
param operatingSystemVersion string

@description('The location of the script.')
param scriptLocation string

@description('The file name of the script.')
param scriptName string

@description('The name of the virtual machine operating system disk.')
param virtualMachineOsDiskName string

@description('The name of the virtual machine public ip address.')
param virtualMachinePublicIpAddressName string

@description('The name of the virtual machine.')
param virtualMachineName string

@description('The name of the virtual machine nic.')
param virtualMachineNicName string

@description('The subnet id of the virtual machine subnet.')
param virtualMachineSubnetId string

@description('The sku of the virtual machine.')
param virtualMachineSku string

@description('The host name of web application 1.')
param webApp1HostName string

@description('The name of web application 1.')
param webApp1Name string

@description('The host name of web application 2.')
param webApp2HostName string

@description('The name of web application 2.')
param webApp2Name string

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
        }
      }
    ]
  }
}

// Resource - Virtual Machine
//////////////////////////////////////////////////
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSku
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: operatingSystemVersion
        version: 'latest'
      }
      osDisk: {
        name: virtualMachineOsDiskName
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: virtualMachineNic.id
        }
      ]
    }
  }
}

// Resource - Custom Script Extension
//////////////////////////////////////////////////
resource virtualMachineCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: virtualMachine
  name: 'CustomScriptextension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptLocation
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File ${scriptName} "${webApp1Name}" "${webApp1HostName}" "${webApp2Name}" "${webApp2HostName}"'
    }
  }
}
