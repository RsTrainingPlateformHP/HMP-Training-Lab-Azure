//on définit les paramètres azures
param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Choisir nom du compte admin et son password')
param vm_username string
@secure()
param vm_password string

//les noms des ressources pour le tp sont mis en place dans le deploymodule
param vnet_tp_name string
param subnet_win string 
param subnet_dc string
param win01_ip string
param winInterface string
param win01 string
param nsg_Win01 string

param dc01 string
param dcInterface string
param dcPublicIP string


//On définit les network security group pour avoir accès au RDP

resource nsg_win01 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: nsg_Win01
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [ 
      {
      name: 'default-allow-rdp'
      properties: {
          priority: 360
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
      } 
    }
    {
      name: 'Allow_http' 
      properties: {
        priority: 350
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourcePortRange: '*'
        sourceAddressPrefix: 'VirtualNetwork'
        destinationAddressPrefix: 'VirtualNetwork'
        destinationPortRange: '80' //port de destination autorisé (http)
      }
    }
    {
      name: 'Allow_https' 
      properties: {
        priority: 370
        protocol: '*'
        access: 'Allow'
        direction: 'Inbound'
        sourcePortRange: '*'
        sourceAddressPrefix: 'VirtualNetwork'
        destinationAddressPrefix: 'VirtualNetwork'
        destinationPortRange: '443' //port de destination autorisé (https)
      }
    }
  ]
  }
}

//Pour ce TP, il nous faut un réseau virtuel avec deux sous réseau (un pour chaque machine)

resource vnet_tp_ad 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnet_tp_name
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.5.0.0/16' //plage d'adresse du réseau virtuel
      ]
    }
    subnets: [
      {
        name: subnet_win //sous réseau pour le client
        properties: {
          addressPrefix: '10.5.0.0/24'
          delegations: []
          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_dc //sous réseau pour le serveur
        properties: {
          addressPrefix: '10.5.1.0/24'
          delegations: []
          
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
    dhcpOptions: {
      dnsServers: [
        '10.5.1.4' //adresse IP du DC comme DNS (pour le TP)
      ]
    }
  }
}

//interface du client pour se connecter à son sous réseau
resource networkInterface_resource 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: winInterface
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet_tp_name, subnet_win)
          }
          
          privateIPAddress: '10.5.0.4'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', win01_ip)
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg_win01.id
    }
  }
  dependsOn: [
    publicIpAddress_resource
  ]
}
//définition d'une adresse IP publique pour accès en RDP
resource publicIpAddress_resource 'Microsoft.Network/publicIpAddresses@2021-08-01' = {
  name: win01_ip
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}
//mise en place du client
resource virtualMachineWIN_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: win01
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
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
        sku: '20h2-ent'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_resource.id
          properties: {
            deleteOption: 'Delete'
            
          }
        }
      ]
    }
    osProfile: {
      computerName: win01
      adminUsername: vm_username
      adminPassword: vm_password
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


resource vmAutoShutdown 'Microsoft.DevTestLab/labs/virtualmachines/schedules@2018-09-15' = {
  name: '${win01}/autoShutdown'
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900' // 19h00
    }
    timeZoneId: 'Romance Standard Time' // Fuseau horaire pour la France
    targetResourceId: win01
  }
}

//définition de l'interface réseau du DC

resource DCnetworkInterface_resource 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: dcInterface
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
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet_tp_name, subnet_dc)
          }
          privateIPAddress: '10.5.1.4'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', dcPublicIP)
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg_win01.id
    }
  }
  dependsOn: [
    DCpublicIpAddress_resource
  ]
}

//IP publique pour RDP
resource DCpublicIpAddress_resource 'Microsoft.Network/publicIpAddresses@2021-08-01' = {
  name: dcPublicIP
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

//mise en place de la vm du DC
resource virtualMachineDC 'Microsoft.Compute/virtualMachines@2021-07-01' ={
  name: dc01
  location: location
  properties: {
    hardwareProfile: {
    vmSize: 'Standard_B2s'
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: DCnetworkInterface_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: dc01
      adminUsername: vm_username
      adminPassword: vm_password
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'Manual'
        }
      }
    }
    licenseType: 'Windows_Server'
  }
}

resource DCAutoShutdown 'Microsoft.DevTestLab/labs/virtualmachines/schedules@2018-09-15' = {
  name: '${dc01}/autoShutdown'
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900' // 19h00
    }
    timeZoneId: 'Romance Standard Time' // Fuseau horaire pour la France
    targetResourceId: dc01
  }
}
