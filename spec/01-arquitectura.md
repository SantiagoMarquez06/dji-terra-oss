# 01 — Arquitectura y mapa de módulos

[COMPROBADO: estructura de archivos + cadenas, 2026-10-30]

## Tres productos en el ISO
| Producto | UI | Motor | Notas |
|---|---|---|---|
| **DJI Terra** 5.3.x | Qt5 (`DJITerra.exe`) + Chromium (`DJIBrowser.exe`) | C++ nativo `map_gen/` + Python/CUDA | Fotogrametría/mapeo |
| **DJI Modify** | Electron+Vue, visor CesiumJS ("Maple") | `main.node` C++ (FFI koffi) | Edición de nube/modelo, proyecto `.dmep` |
| **DJI Reality** | — | — | 595 MB, aún sin analizar |

## Terra: cadena de procesos
`DJI Terra.exe` (lanzador) → `DJITerra.exe` (UI Qt) → orquestadores en `map_gen/`
(`DJIMapGen.exe`, `DJIPicMapGen.exe`, `DJIPicProcess.exe`, `TerraWorkingProcess.exe`) que
cargan el motor.

## Núcleo: `TerraSDK.dll` (67 MB) — biblioteca central del motor
Expone **puntos de entrada por tarea** (todos "version: 5.3.40.0"):
- `RunSFM` — Structure from Motion (poses de cámara + nube dispersa).
- `Reconstruct2D` — reconstrucción 2D: ortomosaico (DOM), DSM, mapas.
- `Reconstruct3D` — malla 3D texturizada.
- `Reconstruct3DGS` — 3D Gaussian Splatting.
- `LidarPostProcessing` — procesado de nube LiDAR.
- `GCPPreview` / `ImagePreview` — marcado de puntos de control / previsualización.
- `GenerateModifyFiles` — genera los archivos para DJI Modify.
- `RunHealthCheck` — chequeo de entorno/hardware.

→ Estos 8 puntos de entrada **son el catálogo de funcionalidades de Terra** y la base del
diseño de `terra-oss`.

## DLL propios de DJI en `map_gen/`
`FastSFM`, `FastCBIR` (recuperación de imágenes), `FastSGM`/`FastPM` (estéreo denso),
`FastMS`, `FastFuse`, `FastDsmBuild`, `FastRF`; `TerraSDK`, `TerraCoordinateSystemSDK`,
`TerraCluster`, `TerraLog`; `dGraph`/`dInfer` (inferencia neuronal: extractor/emparejador
de rasgos — se ven `api_create_feature_extractor_proxy`/`..._matcher_proxy`).

## Librerías de terceros identificadas (reutilizables, ya libres)
- **Qt5** (UI), **GDAL/PROJ** (geo), **FFmpeg** (`av_*`, lectura de vídeo/EXIF),
  **Ceres Solver** (ajuste de haces: Trust Region, Dogleg, Gauss-Newton, `local_BA`),
  **gRPC** (clúster distribuido), **Embree** (trazado de rayos para malla),
  **AWS C++ SDK / S3** (subida a nube), **PyTorch + CUDA/cuDNN/TensorRT** (IA).
