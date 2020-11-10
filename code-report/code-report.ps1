<#
    AUTHOR: MARCO LEWEKE
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]$Path,

    [Parameter(Mandatory=$false)]
    [switch]$CountNoLines,

    [Parameter(Mandatory=$false)]
    [switch]$CountWords,

    [Parameter(Mandatory=$false)]
    [switch]$CountChars,

    [Parameter(Mandatory=$false)]
    [switch]$ResultChart
)
#CONST
$DOUBLE_LINE = ("=" * 50)
$TABLE_LINE = (("-" * 5) + "+" + ("-" * 14) + "+" + ("-" * 14) + "+" + ("-" * 14))
$TABLE_HEADER = ([string]::Format("     |{0,14}|{1,14}|{2,14}", "Total", "Code", "Comment"))
$CHART_HEADER_FILES = [string]::Format("{0,17}|{1,32}", "Content-Type", "Files (%)")
$CHART_HEADER_LINES = [string]::Format("{0,17}|{1,32}", "Content-Type", "Lines (%)")
$CHART_X_AXIS = [string]::Format("{0}+{1}", ("-" * 17), ("-" * 32))
$CHART_SUB = [string]::Format("{0,50:P}", 1) + "`n"

Clear-Host
try
{
    [xml]$Settings = Get-Content .\formats.xml -ErrorAction Stop
    $Types = $Settings.SelectNodes("//type")

    $_types = @()
    $_stats = @()
    foreach($Type in $Types)
    {
        $_type = @{
                    Name = $Type.name
                    Total = 0
                    Extensions = @()
                }
        $TotalLines = 0

        foreach($Extension in $Type.'file-extensions'.'file-extension')
        {
            $Files = 0

            $Lines = @{
                        Total = 0
                        Code = 0
                        Comment = 0
                    }

            $Words = @{
                        Total = 0
                        Code = 0
                        Comment = 0
                    }

            $Chars = @{
                        Total = 0
                        Code = 0
                        Comment = 0
                    }

            $Documents = (Get-ChildItem -Recurse -Include "*.$($Extension.name)" -Path $Path)
            foreach($File in $Documents)
            {
                $Files++
                
                $TmpCommentLines = 0
                $TmpCommentWords = 0
                $TmpCommentChars = 0
                try
                {
                    $MeasureInfo = Get-Content $File -ErrorAction Stop | Measure-Object -Line -Word -Character
                    foreach($CommentMarker in $Extension.'comment-markers'.'comment-marker')
                    {
                        $MeasureCommentsOnly = Get-Content $File -ErrorAction Stop | ? { $Line = $_.Trim(); $Line.StartsWith($CommentMarker) } | Measure-Object -Line -Word -Character
                        $TmpCommentLines += $MeasureCommentsOnly.Lines
                        $TmpCommentWords += $MeasureCommentsOnly.Words
                        $TmpCommentChars += $MeasureCommentsOnly.Characters
                    }
                }
                catch
                {
                    if($File -is [System.IO.FileInfo])
                    {
                        Write-Warning "Cannot load file $File"
                    }
                }
                $Lines.Total += $MeasureInfo.Lines
                $Lines.Code += ($MeasureInfo.Lines - $TmpCommentLines)
                $Lines.Comment += $TmpCommentLines

                $TotalLines += $MeasureInfo.Lines

                $Words.Total += $MeasureInfo.Words
                $Words.Code += ($MeasureInfo.Words - $TmpCommentWords)
                $Words.Comment += $TmpCommentWords

                $Chars.Total += $MeasureInfo.Characters
                $Chars.Code += ($MeasureInfo.Characters - $TmpCommentChars)
                $Chars.Comment += $TmpCommentChars
            }
            $_type.Extensions += @{
                                    Name = $Extension.name
                                    Files = $Files
                                    Lines = $Lines
                                    Words = $Words
                                    Chars = $Chars
                                }
            $_type.Total += $Files
        }
        $_types += $_type
        
        $_stats += @{
                        Name = $Type.name
                        Files = $_type.Total
                        Lines = $TotalLines
                    }
    }
    foreach($Type in $_types)
    {
        if($Type.Total -ne 0)
        {
            Write-Host ([string]::Format("Content-Type: {0,36}", $Type.Name))
            Write-Host ([string]::Format("Total-Files: {0,37}", $Type.Total))
            Write-Host $DOUBLE_LINE

            foreach($Extension in $Type.Extensions)
            {
                if($Extension.Files -gt 0)
                {
                    Write-Host ([string]::Format("File-Extension:" + (" " * 20) + "|{0,14}", ("." + $Extension.Name)))
                    if($Type.Extensions.Count -gt 1)
                    {
                        Write-Host ([string]::Format("Files:" + (" " * 29) + "|{0,14}", $Extension.Files))
                    }
                    Write-Host $TABLE_LINE
                    Write-Host $TABLE_HEADER
                    Write-Host $TABLE_LINE
                    if(! $CountNoLines)
                    {
                        Write-Host ([string]::Format("Lines|{0,14:N}|{1,14:N}|{2,14:N}", $Extension.Lines.Total, $Extension.Lines.Code, $Extension.Lines.Comment))
                    }
                    if($CountWords)
                    {
                        Write-Host ([string]::Format("Words|{0,14:N}|{1,14:N}|{2,14:N}", $Extension.Words.Total, $Extension.Words.Code, $Extension.Words.Comment))
                    }
                    if($CountChars)
                    {
                        Write-Host ([string]::Format("Chars|{0,14:N}|{1,14:N}|{2,14:N}", $Extension.Chars.Total, $Extension.Chars.Code, $Extension.Chars.Comment))
                    }
                    Write-Host $TABLE_LINE
                }
            }
            Write-Host "`n"
        }
    }
    #PRINT CHART
    if($ResultChart)
    {
        $TotalFiles = 0
        $TotalLines = 0
        #SUM UP RESULTS
        foreach($Result in $_stats)
        {
            $TotalFiles += $Result.Files
            $TotalLines += $Result.Lines
        }
        #PRINT RESULTS: FILES
        Write-Host $CHART_HEADER_FILES
        Write-Host $DOUBLE_LINE
        foreach($Result in $_stats)
        {
            if($Result.Files -gt 0)
            {
                $Fraction = ($Result.Files / $TotalFiles)
                $RoundFrac = [math]::Round($Fraction * 100)
                $RoundFrac /= 4
                Write-Host ([string]::Format("{0,17}|{1,-25}{2,7:P}", $Result.Name, ("x" * $RoundFrac), $Fraction))
            }
        }
        Write-Host $CHART_X_AXIS
        Write-Host $CHART_SUB

        #PRINT RESULTS: LINES
        Write-Host $CHART_HEADER_LINES
        Write-Host $DOUBLE_LINE
        foreach($Result in $_stats)
        {
            if($Result.Files -gt 0)
            {
                $Fraction = ($Result.Lines / $TotalLines)
                $RoundFrac = [math]::Round($Fraction * 100)
                $RoundFrac /= 4 #because the chart has a width of 25 points
                Write-Host ([string]::Format("{0,17}|{1,-25}{2,7:P}", $Result.Name, ("x" * $RoundFrac), $Fraction))
            }
        }
        Write-Host $CHART_X_AXIS
        Write-Host $CHART_SUB
    }
}
catch
{
    Write-Error "Cannot find valid 'formats.xml'"
}