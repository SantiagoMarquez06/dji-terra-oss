# 02 — Formatos y bases de datos

## Bases de datos que trae el instalador (recursos estáticos, no proyectos de usuario)

Ubicación: `app/Assistant/map_gen/` y `app/Assistant/db/`. No son SQLite (ninguna tiene
la firma `SQLite format 3`). Se midió su entropía de Shannon para clasificarlas.

| Archivo | Tamaño | sha256 (prefijo) | Entropía | Clasificación |
|---|---|---|---|---|
| cameras.db | 25 600 | 06fc9832… | 7.99/8 | **Cifrada** (sin estructura ni texto) |
| StaticPrecise.db | 19 024 896 | d409da52… | 8.00/8 | **Cifrada** |
| StaticBase.db | 3 901 440 | 4787fc85… | 8.00/8 | **Cifrada** |
| integrity.db | 620 544 | f428d90a… | 8.00/8 | **Cifrada** (anti-manipulación) |
| terra.db | 25 919 533 | 41000903… | 7.41/8 | **Binario propio, sin cifrar** |

[COMPROBADO: medición de entropía y cabeceras, sesión 2026-10-30]

### terra.db — estructura observada
- Cabecera: `00 00 01 00 | 00 00 00 00 | 00 80 00 00 | 00 00 00 00`, seguida de datos.
- Dos regiones: primeros ~8 MB con entropía 6.3–6.5 (tabla estructurada), resto ~7.3.
- El cuerpo inicial es un array de **float32 little-endian** (el byte alto 0x42 se repite
  cada 4 bytes → valores ~30–60). Propósito aún no confirmado; lo consume `TerraSDK.dll`.
- [SUPUESTO: tabla de datos precalculada —calibración/corrección— por el patrón float32 y su ubicación junto al motor]

## Implicación para terra-oss
Cuatro de las cinco bases vienen **cifradas**. Esto NO bloquea el proyecto libre, porque
no necesitamos los datos propietarios de DJI; existen equivalentes abiertos:
- **cameras.db** (probable calibración de cámaras DJI): la calibración la calcula el propio
  SfM (COLMAP) a partir de las fotos; no hace falta la tabla de DJI.
- **StaticPrecise/StaticBase.db** (probable geoide / corrección RTK-PPK): usar modelos de
  geoide públicos (EGM96/EGM2008) vía GDAL/PROJ.
- **integrity.db**: es control de integridad/anti-manipulación de DJI; fuera de alcance.

**Decisión:** no se intentará descifrar estas bases. Recuperar claves para extraer datos
protegidos de DJI sería elusión de una medida técnica y, además, innecesario para la
interoperabilidad. Se usarán datos abiertos equivalentes.

## Modelo de datos de Terra (del scan de cadenas de TerraSDK.dll)
[COMPROBADO: scan de cadenas, 2026-10-30] Terra encadena sus etapas con archivos
**JSON y XML legibles** más formatos estándar de nube/malla/ráster. Casi todo es
documentable e interoperable. Catálogo por categoría:

**Proyecto / tareas (JSON propio de DJI):** `task.json` (incluye clave `CAMERA_DB`),
`sub_task.json`, `task_list.json`, `task_for_2d.json`, `task_for_3d.json`,
`input_data.json`, `parameter.json`, `config.json`, `division.json`, `blocks.json`,
`BlockDivideInfo.json`.

**Aerotriangulación / SfM (JSON + XML):** `sfm_geo_desc.json`, `sfm_report.json`,
`sfm_timing.json`, `at_data.json`, `sorted_images.json`, `image_list.json`,
`original_image_list.json`, `pose.json`, `pose_gt.json`, `camera_info.json`,
`visible_camera_intrinsics.json`, `undist_id.json`, y el XML tipo Bentley/ContextCapture
**`BlocksExchangeUndistortAT.xml`** y `…_WithoutTiePoints.xml` (formato de intercambio AT
conocido → gran valor de interoperabilidad).

**Puntos de control (GCP) / escala:** `gcp_points.json`, `gcp_out.json`, `gcp_ref.json`,
`auto_gcp_markers.json`, `mark_gcp_points.json`, `mark_standard_gcp.json`,
`scale_constraints.json`/`_out.json`.

**Geo / coordenadas:** `geo_desc.json`, `sfm_geo_desc.json`, `lidar_geo_desc.json`,
`geographic_division.json`, `height_transformer.json`, `ROI_box{,_2d,_3d}.json`,
`ROI_local.json`, `aligned_roi.json`, `map_info.json` (ver `03-coordenadas.md`).

**Nubes de puntos (estándar abierto):** `.ply` (`cloud.ply`, `cloud_dense.ply`,
`blocks.ply`, `blocks_tight.ply`, `filter_cloud.ply`, `result_tin.ply`, `mesh.ply`),
`.las`/`.laz`/`.pcd` (`_merged.*`).

**Ráster GeoTIFF (estándar abierto):** `dsm.tif`, `dom.tif`, `dom_prj.tif`, `dsm_local.tif`,
`gsddsm.tif`, `dem.tif`, `_depth.tif`, `_height.tif`, `_overview.tif`, `segment.tif`,
`water_mask.tif`.

**Malla 3D / LOD teselado:** `.osgb` (OpenSceneGraph), **I3S** (Esri), **S3M** (SuperMap),
**b3dm + `tileset.json`** (Cesium 3D Tiles), **3MX** (Bentley), `.obj`. Terra convierte
entre ellos (`convert b3dm to i3s/osgb/s3mb`).

**LiDAR:** `lidar_list.json`, `lidar_geo_desc.json`. **PPK/RTK:** `ppk_list.json`,
`ppk_result.json`, `ppk_time.json`. **Color:** `color_correction_paramters.json` (sic),
`color_harmonization_ref.json`. **Multiespectral/térmico:** `infrared_warp_matrix.json`,
`visible_to_infrared_mapping.json`. **Informes:** `report.json`, `map_report.json`,
`model_report.json`, `densify_report.json`, `3dgs_report.json`.

(Se excluyen `gcloud/application_default_credentials.json` y la URL FBX de Autodesk: son de
librerías de terceros, no formato de DJI.)

### Implicación para terra-oss
- La mayoría son **estándares abiertos** (PLY, LAS/LAZ, PCD, GeoTIFF, OBJ, Cesium 3D Tiles,
  I3S, OSGB, S3M, 3MX) → ya hay librerías libres (PDAL, GDAL, OSG, py3dtiles) para leerlos/escribirlos.
- El trabajo propio de spec se concentra en el **JSON/XML de DJI** (task, sfm_geo_desc,
  camera_info, gcp_*, parameter) y en el **BlocksExchange AT XML**.
- Pendiente: obtener el **esquema exacto** de esos JSON. No están en el instalador (se crean
  al procesar); se sacarán de (a) el código que los escribe en `TerraSDK` (Ghidra, Fase 6),
  (b) el Python/JS legible, o (c) una muestra real / Fase 7.
