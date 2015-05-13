Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [System.String] $Name,
        [Parameter(Mandatory)] [ValidateSet('Private','Public')] [System.String] $Profile
    )
    begin {
        if ([System.Environment]::OSVersion.Version -lt [System.Version]::Parse('6.2')) {
            Write-Error -Message $localizedData.IncorrectOperatingSystemVersionError -Category ResourceUnavailable;
        }
    }
    process {
        $targetResource = @{
            Name = $Name;
            Profile = 'NotFound';
        }
        $netConnectionProfile = Get-NetConnectionProfile | Where-Object InterfaceAlias -Like $Name | Select-Object -First 1;
        if ($netConnectionProfile) {
            Write-Verbose ($localizedData.FoundNetworkAdapterWithProfile -f $netConnectionProfile.InterfaceAlias, $netConnectionProfile.NetworkCategory);
            $targetResource['Name'] = $netConnectionProfile.InterfaceAlias;
            $targetResource['Profile'] = $netConnectionProfile.NetworkCategory;
        }
        switch ($targetResource.Profile) {
            'Domain' {
                    Write-Warning ($localizedData.NetworkAdapterIsDomainJoinedWarning -f $targetResource.Name);
                }
            'DomainAuthenticated' {
                    Write-Warning ($localizedData.NetworkAdapterIsDomainJoinedWarning -f $targetResource.Name);
                }
            'NotFound' {
                    Write-Warning ($localizedData.NetworkAdapterNotFoundWarning -f $targetResource.Name);
                }
        } #end switch profile
        return $targetResource;
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
        $netConnectionProfile = Get-NetConnectionProfile | Where-Object InterfaceAlias -Like $Name | Select-Object -First 1;
        if ($netConnectionProfile) {
            Write-Verbose ($localizedData.SettingNetworkAdapterProfile -f $netConnectionProfile.InterfaceAlias, $Profile);
            $netConnectionProfile | Set-NetConnectionProfile -NetworkCategory $Profile;
        }
    } #end process
} #end function Set-TargetResource
