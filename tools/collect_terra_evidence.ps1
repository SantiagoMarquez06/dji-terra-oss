<#
Recoge la evidencia de formatos de un proyecto DJI Terra ya procesado.
Uso:  .\collect_terra_evidence.ps1 -ProjectDir "C:\ruta\al\proyecto" [-Out "terra_evidence.zip"]
Solo copia archivos de texto pequeños (JSON/XML/log/txt/csv). No toca nubes/mallas ni datos de DJI.
#>
param(
  [Parameter(Mandatory=$true)][string]$ProjectDir,
  [string]$Out = "terra_evidence.zip"
)
if (-not (Test-Path $ProjectDir)) { Write-Error "No existe: $ProjectDir"; exit 1 }
$tmp = Join-Path $env:TEMP ("terra_ev_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tmp | Out-Null
$exts = @('*.json','*.xml','*.log','*.txt','*.csv')
$maxBytes = 5MB
foreach ($e in $exts) {
  Get-ChildItem -Path $ProjectDir -Recurse -File -Filter $e -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -le $maxBytes } | ForEach-Object {
      $rel = $_.FullName.Substring($ProjectDir.Length).TrimStart('\','/')
      $dst = Join-Path $tmp $rel
      New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
      Copy-Item $_.FullName $dst
    }
}
# arbol completo de archivos (nombres y tamaños), sin copiar los grandes
Get-ChildItem -Path $ProjectDir -Recurse -File -ErrorAction SilentlyContinue |
  Select-Object @{n='Rel';e={$_.FullName.Substring($ProjectDir.Length).TrimStart('\','/')}}, Length |
  Sort-Object Rel | ConvertTo-Json -Depth 3 | Out-File (Join-Path $tmp "_file_tree.json") -Encoding utf8
if (Test-Path $Out) { Remove-Item $Out }
Compress-Archive -Path (Join-Path $tmp '*') -DestinationPath $Out
Remove-Item $tmp -Recurse -Force
Write-Host "Listo: $Out  (subelo a un issue o a evidence-runtime/)"
