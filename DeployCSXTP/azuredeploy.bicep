param location string = 'francecentral'
param owner string
param approver string
param endDate string

var VM_FE_WINDOWS_name = 'VM-CSX-TP-LINUX'
var VM_FE_LINUX_name = 'VM-CSX-TP-WINDOWS'
var VM_BE_SERVER_name = 'VM-CSX-TP-SERVER'

var VNET_name = 'VNET-Lab-CSX'
var NSG_Name = 'nsg-CSX-TP'

var ImageID_VM_FE_WINDOWS = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_CSX_WINDOWS_VM/versions/latest'
var ImageID_VM_FE_LINUX = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_CSX_LINUX_VM/versions/latest'
var ImageID_VM_BE_SERVER = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_CSX_SERVER_VM/versions/latest'

resource Application_Security_Group_FE 'Microsoft.Network/applicationSecurityGroups@2021-05-01' = {
  name: 'FrontEndServer'
  location : location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
}

resource Application_Security_Group_BE 'Microsoft.Network/applicationSecurityGroups@2021-05-01' = {
  name: 'BackEndServer'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
}

resource publicIP_VM_FE_Windows 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${VM_FE_WINDOWS_name}-public-IP'
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

resource publicIP_VM_FE_LINUX 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${VM_FE_LINUX_name}-public-IP'
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

resource VNET_TP_CSX 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: VNET_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.3.0.0/24'
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

resource NSG_TP_CSX 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: NSG_Name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
      securityRules: [
        {
          name: 'SSH_FE_BE'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceApplicationSecurityGroups: [
              {
                id: Application_Security_Group_FE.id
                location: location
              }
            ]
            destinationPortRange: '22'
            destinationApplicationSecurityGroups: [
              {
                id: Application_Security_Group_BE.id
                location: location
              }
            ]
            access: 'Allow'
            priority: 100
            direction: 'Inbound'
          }
        }
        {
          name: 'RDP_Inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '3389'
            sourceAddressPrefix: '*'
            destinationApplicationSecurityGroups: [
              {
                id: Application_Security_Group_FE.id
                location: location
              }
            ]
            access: 'Allow'
            priority: 110
            direction: 'Inbound'
          }
        }
        {
          name: 'SSH_Inbound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            destinationPortRange: '22'
            sourceAddressPrefix: '*'
            destinationApplicationSecurityGroups: [
              {
                id: Application_Security_Group_FE.id
                location: location
              }
            ]
            access: 'Allow'
            priority: 120
            direction: 'Inbound'
          }
        }
        {
          name: 'RestrictVNetFlowInbound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Deny'
            priority: 300
            direction: 'Inbound'
          }
        }
        {
          name: 'RestrictVNetFlowOutbould'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            destinationPortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Deny'
            priority: 300
            direction: 'Outbound'
          }
        }
      ]
  }
}

resource networkInterface_VM_FE_Windows 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_FE_WINDOWS_name}-network-interface'
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
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP_VM_FE_Windows.id
          }
          subnet: {
            id: VNET_TP_CSX.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationSecurityGroups: [
            {
              id: Application_Security_Group_FE.id
            }            
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_CSX.id
    }
  }
}

resource networkInterface_VM_FE_LINUX 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_FE_LINUX_name}-network-interface'
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
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP_VM_FE_LINUX.properties.subnets[0].id
          }
          subnet: {
            id: VNET_TP_CSX.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationSecurityGroups: [
            {
              id: Application_Security_Group_FE.id
            }            
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_CSX.id
    }
  }
}

resource networkInterface_VM_BE_SERVER 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_BE_SERVER_name}-network-interface'
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
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: VNET_TP_CSX.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationSecurityGroups: [
            {
              id: Application_Security_Group_BE.id
            }            
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_CSX.id
    }
  }
}

resource VM_FE_WINDOWS 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: VM_FE_WINDOWS_name
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
      imageReference: {
        id: ImageID_VM_FE_WINDOWS
      }
      osDisk: {
        name: '${VM_FE_WINDOWS_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_FE_Windows.id
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

resource VM_FE_LINUX 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: VM_FE_LINUX_name
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
      imageReference: {
        id: ImageID_VM_FE_LINUX
      }
      osDisk: {
        name: '${VM_FE_LINUX_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_FE_LINUX.id
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

resource VM_BE_SERVER 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: VM_BE_SERVER_name
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
      imageReference: {
        id: ImageID_VM_BE_SERVER
      }
      osDisk: {
        name: '${VM_BE_SERVER_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_BE_SERVER.id
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

output Public_IP_VM_FE_Windows string = publicIP_VM_FE_Windows.properties.ipAddress
output Public_IP_VM_FE_Linux string = publicIP_VM_FE_LINUX.properties.ipAddress
output Private_IP_VM_BE_SERVER string = networkInterface_VM_BE_SERVER.properties.ipConfigurations[0].properties.privateIPAddress
