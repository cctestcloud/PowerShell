PS C:\WINDOWS\system32> history

  Id CommandLine
  -- -----------
   1 Connect-AzAccount
   2 $virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'US East' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16
   3 Get-AzureRmTag
   4 $virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'US East' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16 -Tag @{Owner="Jeff"}
   5 $virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'East US' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16 -Tag @{Owner="Jeff"}
   6 $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Backbone -AddressPrefix 172.28.1.0/24 -VirtualNetwork $virtualnetwork -Tag @{Owner="Jeff"}
   7 $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Backbone -AddressPrefix 172.28.1.0/24 -VirtualNetwork $virtualnetwork
   8 $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Auth -AddressPrefix 172.28.2.0/24 -VirtualNetwork $virtualnetwork
   9 $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Web -AddressPrefix 172.28.3.0/24 -VirtualNetwork $virtualnetwork
  10 $virtualnetwork | Set-AzVirtualNetwork
  11 Get-AzVirtualNetwork
  12 Get-AzVirtualNetwork | more

