function Get-AbrADDHCPv6PerScopeSetting {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Microsoft AD DHCP Servers IPv6 Scopes Server Options from DHCP Servers
    .DESCRIPTION

    .NOTES
        Version:        0.7.6
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
    .EXAMPLE

    .LINK

    #>
    [CmdletBinding()]
    param (
        [Parameter (
            Position = 0,
            Mandatory)]
            [string]
            $Domain,
            [string]
            $Server,
            $Scope
    )

    begin {
        Write-PscriboMessage "Discovering DHCP Servers Scope Server Options information on $($Server.ToUpper().split(".", 2)[0])."
    }

    process {
        $DHCPScopeOptions = Get-DhcpServerv6OptionValue -CimSession $TempCIMSession -ComputerName $Server -Prefix $Scope
        if ($DHCPScopeOptions) {
            Section -ExcludeFromTOC -Style NOTOCHeading5 $Scope {
                Paragraph "The following section provides a summary of the DHCP servers IPv6 Scope Server Options information."
                BlankLine
                $OutObj = @()
                foreach ($Option in $DHCPScopeOptions) {
                    try {
                        Write-PscriboMessage "Collecting DHCP Server IPv6 Scope Server Option value $($Option.OptionId) from $($Server.split(".", 2)[0])"
                        $inObj = [ordered] @{
                            'Name' = $Option.Name
                            'Option Id' = $Option.OptionId
                            'Type' = $Option.Type
                            'Value' = $Option.Value
                        }
                        $OutObj += [pscustomobject]$inobj
                    }
                    catch {
                        Write-PscriboMessage -IsWarning "$($_.Exception.Message) (IPv6 Scope Options Item)"
                    }
                }
                $TableParams = @{
                    Name = "IPv6 Scopes Options - $Scope"
                    List = $false
                    ColumnWidths = 40, 15, 20, 25
                }
                if ($Report.ShowTableCaptions) {
                    $TableParams['Caption'] = "- $($TableParams.Name)"
                }
                $OutObj | Sort-Object -Property 'Option Id' | Table @TableParams
            }
        }
    }

    end {}

}