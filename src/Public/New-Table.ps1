function New-Table {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions")]
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