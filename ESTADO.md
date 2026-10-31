# Estado del proyecto — qué se logró y qué falta

_Actualizado: 2026-10-30. Análisis estático hecho en un equipo sin GPU NVIDIA._

## ✅ Lo que YA se obtuvo (análisis estático, sin ejecutar el programa)
- **Arquitectura completa** de DJI Terra, Modify y Reality: lenguajes, módulos y cómo se
  conectan. → `spec/01-arquitectura.md`
- **Catálogo de funcionalidades** = las 8 tareas del motor (`TerraSDK`): RunSFM,
  Reconstruct2D, Reconstruct3D, Reconstruct3DGS, LidarPostProcessing, GCPPreview,
  ImagePreview, GenerateModifyFiles, HealthCheck. → `spec/01`, `spec/04`
- **Inventario de formatos**: modelo de datos JSON/XML de Terra + formatos abiertos
  (PLY, LAS/LAZ, PCD, GeoTIFF, OBJ, OSGB, I3S, S3M, Cesium 3D Tiles, 3MX). → `spec/02`
- **Sistema de coordenadas**: usa GDAL/OGR (EPSG 4326/3857/4978/UTM, GCJ-02) y geoide
  público EGM2008. → `spec/03`
- **Pipeline interno**: ajuste de haces con Ceres, clúster gRPC, extractor/emparejador de
  rasgos neuronal, soporte térmico/multiespectral; con el **mapa a librerías libres**
  (COLMAP, OpenMVS, PDAL, gsplat, GDAL). → `spec/04`
- **IA / 3DGS**: es CUDA nativo + modelo cifrado (no Python legible). → `spec/05`
- **DJI Modify**: Electron + Vue + visor CesiumJS; proyecto `.dmep`. → `spec/06`
- **Repositorio ordenado** (spec/src/tools) y **guía llave en mano** para colaboradores con GPU.

## ❌ Lo que FALTA (y por qué)
- **Esquemas EXACTOS de los JSON/XML** (campos y tipos): no están en el instalador; Terra
  los crea al procesar. Requiere **procesar un proyecto real** → necesita GPU NVIDIA.
  Tarea preparada en `spec/08-runtime.md` + `tools/collect_terra_evidence.ps1`.
- **Comportamiento real en ejecución** (orden fino de etapas, parámetros por defecto, qué
  datos van a la nube de DJI): igual, requiere ejecutar Terra en hardware con GPU.
- **Decompilación profunda del núcleo nativo** (`TerraSDK`, `Fast*`, `main.node`): muy lenta
  sin mejor hardware; objetivos listados en `spec/07-nativo.md`.
- **Partes cifradas/propietarias** (modelo `ai_fm`, bases `.db`, `background.js` de Modify):
  **fuera de alcance a propósito** (sería elusión y no hace falta: hay equivalentes libres).
- **Implementación `src/`**: aún sin código; se construye una vez cerradas las specs.

## 🚧 Causa raíz del bloqueo
El equipo de análisis tiene GPU Intel HD 4000 (sin CUDA), i3-3217U y 12 GB RAM. DJI Terra
**exige GPU NVIDIA** para procesar. Por eso toda la parte dinámica se delega a un colaborador
con PC capaz (ver `CONTRIBUTING.md`).
