<#
  New package from the master model folder (-Master: the folder that holds Contoso-Retail.pbip) and a .tmdl that defines the HTML measure (-MeasureSource).
#>
param([string]$Name,[string]$Measure,[string]$Page,[string]$Tag,[Parameter(Mandatory)][string]$Master,[Parameter(Mandatory)][string]$MeasureSource)
$src=$Master
$g=Split-Path $PSScriptRoot -Parent
$d="$g\$Name"
New-Item -ItemType Directory "$d\pbip" -Force | Out-Null
Copy-Item "$src\Contoso-Retail.pbip" "$d\pbip\$Name.pbip"
foreach($x in 'Report','SemanticModel'){ robocopy "$src\Contoso-Retail.$x" "$d\pbip\$Name.$x" /E /XD .pbi /NFL /NDL /NJH /NJS | Out-Null }
(Get-Content "$d\pbip\$Name.pbip" -Raw).Replace('Contoso-Retail',$Name) | Set-Content "$d\pbip\$Name.pbip" -NoNewline -Encoding utf8
$pb="$d\pbip\$Name.Report\definition.pbir"; (Get-Content $pb -Raw).Replace('Contoso-Retail',$Name) | Set-Content $pb -NoNewline -Encoding utf8
$rj="$d\pbip\$Name.Report\definition\report.json"; $j=Get-Content $rj -Raw | ConvertFrom-Json; $j.publicCustomVisuals=@($j.publicCustomVisuals)+'htmlContent443BE3AD55E043BF878BED274D3A6865' | Select -Unique; $j | ConvertTo-Json -Depth 60 | Set-Content $rj -Encoding utf8
# measure from the catalog, renamed to the master's names
$cat=Get-Content $MeasureSource -Raw
$i=$cat.LastIndexOf("`t///",$cat.IndexOf("measure '$Measure'")); if($i -lt 0 -or $cat.Substring($i,$cat.IndexOf("measure '$Measure'")-$i).Contains("measure ")){ $i=$cat.IndexOf("`tmeasure '$Measure'") }
$k=$cat.IndexOf("lineageTag:",$cat.IndexOf("measure '$Measure'")); $k=$cat.IndexOf("`n",$k)
$blk=$cat.Substring($i,$k-$i).TrimEnd().Replace('[Sales Amount]','[Total Sales]').Replace('[PY Sales Amount]','[Sales PY]').Replace("'DimProduct'[Category]","'DimProduct'[CategoryName]") -replace 'lineageTag: [0-9a-f-]+',"lineageTag: 5e1c0a00-0000-4000-8000-0000000000$Tag"
$mf="$d\pbip\$Name.SemanticModel\definition\tables\Metric.tmdl"; $t=Get-Content $mf -Raw; $p=$t.IndexOf("`n`tcolumn "); if($p -lt 0){$p=$t.IndexOf("`n`tpartition ")}; Set-Content $mf $t.Insert($p+1,"$blk`n`n") -NoNewline -Encoding utf8
# page 2: copy the calendar page (year 2024 filter) and point its visual at the measure
$pg="$d\pbip\$Name.Report\definition\pages"; robocopy "$g\Calendario_Ventas\pbip\Calendario_Ventas.Report\definition\pages\page2" "$pg\page2" /E /NFL /NDL /NJH /NJS | Out-Null
(Get-Content "$pg\page2\page.json" -Raw).Replace('Calendario de ventas',$Page) | Set-Content "$pg\page2\page.json" -NoNewline -Encoding utf8
$v="$pg\page2\visuals\html-calendario\visual.json"; (Get-Content $v -Raw).Replace('HTML Calendar Month Weekday',$Measure).Replace('"html-calendario"','"html-visual"') | Set-Content $v -NoNewline -Encoding utf8; Rename-Item "$pg\page2\visuals\html-calendario" 'html-visual'
$pj=Get-Content "$pg\pages.json" -Raw | ConvertFrom-Json; $pj.pageOrder=@($pj.pageOrder)+'page2' | Select -Unique; $pj.activePageName='page2'; $pj | ConvertTo-Json | Set-Content "$pg\pages.json" -Encoding utf8
Write-Host "built $Name"
