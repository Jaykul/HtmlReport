function New-Chart {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param(
        # Chart Type
        [ChartType]$ChartType,

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
        [Emphasis]$Emphasis = "default"
    )
    begin {
        $ChartData = @()
    }
    process {
        $ChartData += $InputObject
    }
    end {
        $Chart = [Chart]::new($Title, [PSObject]$ChartData, $Description, $Emphasis)
        $Chart.ChartType = $ChartType
        $Chart
    }
}