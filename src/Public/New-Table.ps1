function New-Table {
    #.Synopsis
    #   Creates a new TableData object for rendering in New-Report
    #.Example
    #   Get-ChildItem C:\Users -Directory | 
    #       Select LastWriteTime, @{Name="Length"; Expression={ 
    #           (Get-ChildItem $_.FullName -Recurse -File -Force | Measure Length -Sum).Sum
    #       } }, Name |
    #       New-Table -Title $Pwd -Description "Full file listing from $($Pwd.Name)"
    #
    #   Collect the list of user directories and measure the size of each
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param(
        # A title that goes on the top of the table
        [Parameter(Mandatory)]
        [string]$Title,

        # Description to go above the table
        [Parameter()]
        [string]$Description,

        # Data for the table (can be piped in)
        [Parameter(Mandatory,ValueFromPipeline)]
        [PSObject]$InputObject,

        # Emphasis value: default (unadorned), primary (highlighted), success (green), info (blue), warning (yellow), danger (red)
        [Parameter()]
        [Emphasis]$Emphasis = "primary"
    )
    begin {
        $TableData = @()
    }
    process {
        $TableData += $InputObject
    }
    end {
        [Table]::new($Title, [PSObject]$TableData, $Description, $Emphasis)
    }
}