param location string = resourceGroup().location
param virtualMachineName string = 'VM-Splunk'


var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetName = 'VNET-TP-Splunk'
var subnetRef = '${vnetId}/subnets/${subnetName}'
var imageID = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/from_snapshot_linux/versions/1.0.0'
var networkInterfaceName = '${virtualMachineName}-networkInterface'
var networkSecurityGroupName = '${virtualMachineName}-NSG'
var subnetName = 'Splunk_Default_Subnet'
var virtualMachineSize = 'Standard_B4ms'

var publicIpAddressName = 'splunkVm-IP'
var publicIpAddressType  = 'Dynamic'
var publicIpAddressSku  = 'Standard'

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  }

var vnetId = virtualNetwork_resource.id

resource networkInterfaceSplunk 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    publicIpAddressSplunk
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
}

resource publicIpAddressSplunk 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
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
        sharedGalleryImageId: imageID
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceSplunk.id
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

resource shutdown_computevm_virtualMachineName 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${virtualMachineName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '19:00:00'
    }
    timeZoneId: 'Romance Standard Time'
    targetResourceId: virtualMachineName_resource.id
    notificationSettings: {
      status: 'Disabled'

    }
  }
}
