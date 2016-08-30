function New-Chart {
    #.Synopsis
    #   Creates a new ChartData for New-Report
    #.Description
    #   Collects ChartData for New-Report.
    #   ChartData should be in specific shapes in order to work properly, but it depends somewhat on the chart type you're trying to create (LineChart, PieChart, ColumnChart, BarChart, AreaChart, ScatterChart, GeoChart, Timeline). There should be examples for each in the help below...  
    #.Notes
    #   TODO: Write examples...
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