
param location string = 'francecentral'
param owner string
param approver string
param endDate string



resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: 'beijawin01895'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: 'RG_TP_AD-vnet01_windows'
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', 'BeijaWIN01-ip')
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: 'BeijaWIN01-nsg'
    }
  }
  dependsOn: [
    publicIpAddressName_resource
  ]
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2021-08-01' = {
  name: 'BeijaWIN01-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: 'BeijaWIN01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A4_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-ent'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    osProfile: {
      computerName: 'BeijaWIN01'
      adminUsername: 'AdminAdminAdmin'
      adminPassword: 'AdminAdminAdmin'
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'Manual'
        }
      }
    }
    licenseType: 'Windows_Client'
  }
}
