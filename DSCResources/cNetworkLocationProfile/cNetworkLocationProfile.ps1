Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateSet('Private','Public')] [System.String] $Profile
    )
    process {
        # Get network connections
        $iNetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'));
        $iNetworkConnections = $iNetworkListManager.GetNetworkConnections();
        $targetResource = @{
            Name = $Name;
            Profile = 'NotFound';
        }

        foreach ($iNetworkConnection in $iNetworkConnections) {
            $networkName = $iNetworkConnection.GetNetwork().GetName();
            if ($networkName -like $Name) {
                $networkCategory = $iNetworkConnection.GetNetwork().GetCategory();
                $targetResource['Name'] = $networkName;
                Write-Verbose ($localizedData.FoundNetworkLocationWithCategory -f $networkName, $networkCategory);
            }
            
            switch ($networkCategory) {
                0 { $targetResource['Profile'] = 'Public'; }
                1 { $targetResource['Profile'] = 'Private'; }
                2 { $targetResource['Profile'] = 'Domain'; }
                Default { $targetResource['Profile'] = 'NotFound'; }
            }
        } #end foreach network connection

        switch ($targetResource.Profile) {
            'Domain' {
                    Write-Warning ($localizedData.NetworkLocationIsDomainJoinedWarning -f $targetResource.Name);
                }
            'NotFound' {
                    Write-Warning ($localizedData.NetworkLocationNotFoundWarning -f $targetResource.Name);
                }
        } #end switch profile
        
        return $targetResource;
        ## http://blogs.technet.com/b/samdrey/archive/2011/10/19/how-to-use-powershell-to-change-the-network-location-type-to-private-or-public.aspx
    } #end process
} #end Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateSet('Private','Public')] [System.String] $Profile
    )
    process {
        $targetResource = Get-TargetResource @PSBoundParameters;
        if ($targetResource.Name -like $Name -and $Profile -eq $targetResource.Profile) {
            Write-Verbose ($localizedData.ResourceInDesiredState -f $targetResource.Name);
            return $true;
        }
        else {
            Write-Verbose ($localizedData.ResourceNotInDesiredState -f $targetResource.Name);
            return $false;
        }
    } #end process
} #end function Test-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateSet('Private','Public')] [System.String] $Profile
    )
    process {
        # Get network connections
        $iNetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}'));
        $iNetworkConnections = $iNetworkListManager.GetNetworkConnections();

        foreach ($iNetworkConnection in $iNetworkConnections) {
            $networkName = $iNetworkConnection.GetNetwork().GetName();
            if ($networkName -like $Name) {
                switch ($Profile) {
                    'Public' { $networkCategory = 0; }
                    'Private' { $networkCategory = 1; }
                }
                Write-Verbose ($localizedData.SettingNetworkLocationProfile -f $networkName, $Profile);
                $iNetworkConnection.GetNetwork().SetCategory($networkCategory);
            }
        } #end foreach network connection
    } #end process
} #end function Set-TargetResource
