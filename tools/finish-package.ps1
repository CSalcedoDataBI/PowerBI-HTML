param([string]$Name,[string]$Measure,[string]$Title,[string]$Slug,[string]$Page,[string]$Intro,[string]$Needs)
$g=Split-Path $PSScriptRoot -Parent; $d="$g\$Name"
node -e "const s=require('sharp');(async()=>{const r=process.argv[1];const b=await s(r+'/preview.png').flatten({background:'#fff'}).trim({background:'#fff',threshold:8}).toBuffer();await s(b).resize(1520,820,{fit:'contain',background:'#fff'}).extend({top:40,bottom:40,left:40,right:40,background:'#fff'}).png().toFile(r+'/card.png')})()" $d
$t=Get-Content "$d\pbip\$Name.SemanticModel\definition\tables\Metric.tmdl" -Raw; $a=$t.IndexOf("measure '$Measure'"); $b=$t.IndexOf("lineageTag:",$a)
$meas=($t.Substring($a,$b-$a).TrimEnd() -replace "(?m)^\t\t\t",'' -replace '^measure ','')
"-- The HTML: put this measure in an HTML Content visual. Uses [Total Sales], [Sales PY] and DimProduct columns of Contoso-Retail.`n$meas`n" | Set-Content "$d\$Slug.dax" -Encoding utf8
@"
# $Title

$Intro

Ficha y vista previa: <https://csalcedodatabi.com/recursos/galeria-html/$Slug>

![$Title](preview.png)

---

## Abre y pinta

El informe usa **Contoso-Retail** (2023–2024), el modelo maestro de la galería, con los datos de [SampleDataSets](https://github.com/CSalcedoDataBI/SampleDataSets) (MIT) leídos por internet. Descomprimes, abres ``pbip/$Name.pbip`` en Power BI Desktop, pulsas **Actualizar** la primera vez y el visual está en la página **«$Page»**, filtrada al año 2024.

``````
$Name/
├── pbip/          el informe + su modelo, en texto
├── $Slug.dax      la medida HTML, para copiar
└── $Name.zip      todo lo anterior
``````

## Cómo lo conecto a MIS datos

1. Copia la medida ``$Measure`` de ``$Slug.dax``.
2. $Needs
3. Ponla en un visual **HTML Content** y filtra un año en la página.

## Licencia

MIT — ver [LICENSE](../LICENSE). Hecho por [CSalcedoDataBI](https://csalcedodatabi.com).
"@ | Set-Content "$d\README.md" -Encoding utf8
$cell="<td align=`"center`" width=`"50%`"><a href=`"$Name/`"><img src=`"$Name/card.png`" width=`"100%`" alt=`"$Title`"></a><br><b><a href=`"$Name/`">$Title</a></b></td>"
$f="$g\README.md"; $r=Get-Content $f -Raw
if($r.Contains('<td width="50%"></td></tr>')){ $r=$r.Replace('<td width="50%"></td></tr>',"$cell</tr>") } else { $r=$r.Replace("</tr>`n</table>","</tr>`n<tr>$cell<td width=`"50%`"></td></tr>`n</table>").Replace("</tr>`r`n</table>","</tr>`r`n<tr>$cell<td width=`"50%`"></td></tr>`r`n</table>") }
Set-Content $f $r -NoNewline -Encoding utf8
Push-Location $g; pwsh -NoProfile -File tools/build-zip.ps1 $Name; pwsh -NoProfile -File tools/check-package.ps1 $Name; Pop-Location
