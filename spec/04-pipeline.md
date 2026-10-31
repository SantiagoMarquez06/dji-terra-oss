# 04 — Pipeline de procesamiento y parámetros

[COMPROBADO: cadenas de `TerraSDK.dll`, 2026-10-30. Los esquemas exactos de los JSON se
cerrarán con muestras reales — ver `08-runtime.md`.]

## Las 8 tareas del motor (= funcionalidades)
Cada tarea lee/escribe los JSON del `02-formatos.md`. Secuencia típica foto→producto:

1. **RunSFM** — entrada: imágenes + `image_list.json`/`sorted_images.json` + POS/RTK
   (`ppk_*`). Hace extracción y emparejado de rasgos (extractor/matcher **neuronal** vía
   `dInfer`/`dGraph`, API `api_create_feature_*_proxy`) + ajuste de haces con **Ceres**
   (`local_BA`, Trust Region/Dogleg). Salida: poses y nube dispersa →
   `sfm_geo_desc.json`, `camera_info.json`, `at_data.json`, `sparse .ply`,
   `BlocksExchangeUndistortAT.xml` (intercambio tipo ContextCapture).
2. **Reconstruct2D** — ortomosaico `dom.tif`, `dsm.tif`/`gsddsm.tif`, mapas 2D, curvas de
   nivel (`Generate_contourline`), informes `map_report.json`.
3. **Reconstruct3D** — estéreo denso (`FastSGM`/`FastPM`) → fusión (`FastFuse`) → malla
   (Embree) → texturizado → LOD teselado (`.osgb`/I3S/S3M/b3dm+`tileset.json`/3MX).
   Incluye "water surface completion" y suavizado (`[Smooth]`).
4. **Reconstruct3DGS** — 3D Gaussian Splatting (CUDA, ver `05-ia.md`) → `3dgs_report.json`.
5. **LidarPostProcessing** — nube LiDAR (`lidar_list.json`, `lidar_geo_desc.json`) →
   `.las`/`.laz`/`.pcd` fusionados, DSM, 2D lidar, curvas de nivel.
6. **GCPPreview / ImagePreview** — marcado manual/automático de GCP (`gcp_*.json`,
   `auto_gcp_markers.json`) y previsualización.
7. **GenerateModifyFiles** — empaqueta resultados para DJI Modify (`.dmep`).
8. **RunHealthCheck** — valida GPU/driver (CUDA, "driver >= …"), memoria y disco.

## Modos de ejecución
- **Stand-alone** vs **cluster** ("Run step in stand alone/cluster mode"): el motor puede
  distribuirse por **gRPC** (`TerraCluster`, `[ClusterCoreSDK]`).
- Divide el trabajo en **bloques** (`BlockDivideInfo.json`, `division.json`,
  `geographic_division.json`) para paralelizar/ahorrar memoria.

## Soportes especiales observados
- **Térmico/multiespectral**: `ambient_temperature`, `atmospheric_temperature`,
  `aux_band_list`, `visible_to_infrared_mapping.json`, `all_thermal_routes_hd_mode`.
- **Corrección de color**: `color_correction_paramters.json`, `color_harmonization_ref.json`.

## Mapa a bloques libres (terra-oss)
RunSFM→**COLMAP**/GLOMAP (+ rasgos neuronales tipo SuperPoint/DISK opcional); denso+malla→
**OpenMVS**; LiDAR→**PDAL**; ortofoto/DSM→**GDAL**/OpenDroneMap; 3DGS→**gsplat**;
teselado 3D→**py3dtiles**/CesiumJS; clúster→orquestador propio.
