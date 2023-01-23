param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Choisir nom du cmpte admin et son password')
param VM_WINDOWS_name string
param VM_LINUX_name string
param VM_SERVER_name string

param VNET_name string
param NSG_Name string

var ImageID_VM_WINDOWS = ''
var ImageID_VM_LINUX = ''
var ImageID_VM_SERVER = ''


resource publicIP_VM_SERVER 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_SERVER_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}


resource VNET_TP_NESSUS 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${VNET_name}${uniqueString(subscription().subscriptionId, deployment().name)}'
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.4.0.0/16' //plage d'adresse du réseau virtuel
      ]
    }
    subnets: [
      { 
        name: 'default' //specs obligatoires
        properties: {
          addressPrefix: '10.4.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }   
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource NSG_TP_NESSUS 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: NSG_Name
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [
      {
        name: 'default-allow-rdp' //nom de la règle
        properties: {
          priority: 1000
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefixes: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'         
          destinationPortRange: '3389' //port de destination autorisé (rdp)
        }
      }
    ]
  }
}

resource networkInterface_VM_WINDOWS 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${VM_WINDOWS_name}-network-interface'
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
            id: VNET_TP_NESSUS.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.4.0.5'
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_NESSUS.id
    }
  }
}

resource networkInterface_VM_LINUX 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${VM_LINUX_name}-network-interface'
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
            id: VNET_TP_NESSUS.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.4.0.4'
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_NESSUS.id
    }
  }
}

resource networkInterface_VM_SERVER 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_SERVER_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.4.0.3'
          publicIPAddress: {
            id: publicIP_VM_SERVER.id
          }
          subnet: {
            id: VNET_TP_NESSUS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_NESSUS.id
    }
  }
}

resource VM_WINDOWS 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_WINDOWS_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_WINDOWS_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_WINDOWS
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_WINDOWS.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }  
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_LINUX 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_LINUX_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_LINUX_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_LINUX
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_LINUX.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }  
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
resource VM_SERVER 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_SERVER_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_SERVER_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_SERVER
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_SERVER.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }  
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
