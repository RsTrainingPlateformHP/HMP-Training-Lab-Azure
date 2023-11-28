param location string = 'francecentral'

param owner string
param approver string
param endDate string

param VM_EJBCA_name string

param VNET_name string
param NSG_name string

var ImageID_VM_EJBCA = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourcegroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_ejbca_vm/versions/1.0.0'

//////////////////////////////////////////////////////////////////////////////////SERVER PUBLIC IP/////////////////////////////////////////////////////////////////////////////////////

resource publicIP_VM_EJBCA 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_EJBCA_name}-public-IP'
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

//////////////////////////////////////////////////////////////////////////////////VNET/////////////////////////////////////////////////////////////////////////////////////////////////

resource VNET_TP_EJBCA 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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
        '192.168.0.0/16' //plage d'adresse du réseau virtuel
      ]
    }
    subnets: [
      {
        name: 'default' //specs obligatoires
        properties: {
          addressPrefix: '192.168.0.0/24'
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

//////////////////////////////////////////////////////////////////////////////////Network Security Groups//////////////////////////////////////////////////////////////////////////////

resource NSG_TP_EJBCA 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: NSG_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [
      {
        name: 'Allow_SSH'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow_RDP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Inbound'
        }
      }
    ]
  }
}

//////////////////////////////////////////////////////////////////////////////////Network Interface////////////////////////////////////////////////////////////////////////////////////

resource networkInterface_VM_EJBCA 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_EJBCA_name}-network-interface'
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
          privateIPAddress: '192.168.0.4'
          publicIPAddress: {
            id: publicIP_VM_EJBCA.id
          }
          subnet: {
            id: VNET_TP_EJBCA.properties.subnets[0].id
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
      id: NSG_TP_EJBCA.id
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////Virtual Machines/////////////////////////////////////////////////////////////////////////////////////

resource VM_EJBCA 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_EJBCA_name
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
        name: '${VM_EJBCA_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_EJBCA
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_EJBCA.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
