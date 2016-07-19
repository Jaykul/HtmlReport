$PSModuleRoot = $PSScriptRoot

enum Emphasis {
  default
  primary
  success
  info
  warning
  danger
}

enum ChartType {
  LineChart
  PieChart
  ColumnChart
  BarChart
  AreaChart
  ScatterChart
  GeoChart
  Timeline
}

class DataWrapper {
    DataWrapper([string]$Title, [PSObject]$Data) {
        $this.Title = $Title
        $this.Data = $Data
    }

    DataWrapper([string]$Title, [PSObject]$Data, [string]$Description) {
        $this.Title = $Title
        $this.Description = $Description
        $this.Data = $Data
    }

    DataWrapper([string]$Title, [PSObject]$Data, [string]$Description, [Emphasis]$Emphasis) {
        $this.Title = $Title
        $this.Description = $Description
        $this.Emphasis = $Emphasis
        $this.Data = $Data
    }

    [string]$Title = ""
    [string]$Description = ""
    [Emphasis]$Emphasis = "default"
    [PSObject]$Data = $null
}

class Table : DataWrapper {
    Table([string]$Title, [PSObject]$Data) : base($Title, $Data) {}
    Table([string]$Title, [PSObject]$Data, [string]$Description) : base($Title, $Data, $Description) {}
    Table([string]$Title, [PSObject]$Data, [string]$Description, [Emphasis]$Emphasis) : base($Title, $Data, $Description, $Emphasis) {}
}

class Chart : DataWrapper {
    Chart([string]$Title, [PSObject]$Data) : base($Title, $Data) {}
    Chart([string]$Title, [PSObject]$Data, [string]$Description) : base($Title, $Data, $Description) {}
    Chart([string]$Title, [PSObject]$Data, [string]$Description, [Emphasis]$Emphasis) : base($Title, $Data, $Description, $Emphasis) {}
    [ChartType]$ChartType = "Line"
}