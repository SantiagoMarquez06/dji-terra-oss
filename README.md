# dji-terra-oss

Proyecto para construir una **alternativa libre e interoperable a DJI Terra** mediante
ingeniería inversa *clean-room*. Documenta el comportamiento de DJI Terra 5.3.5 (y de DJI
Modify/Reality) y, a partir de esa especificación, implementa un equivalente con tecnología
libre.

> **Objetivo:** interoperabilidad y software libre. **No** se cubre el saltado de licencia
> (CodeMeter) ni ataques a servidores de DJI. No contiene binarios, modelos ni datos de DJI.

## Estructura
- **`spec/`** — especificaciones de comportamiento (entradas → transformación → salidas),
  con cada afirmación marcada `[COMPROBADO]`/`[SUPUESTO]`. Empieza por `spec/01-arquitectura.md`.
- **`src/`** — implementación libre (spec-first; en preparación).
- **`tools/`** — utilidades, p. ej. el script de captura de evidencia en ejecución.

## Estado (2026-10-30)
Análisis **estático** hecho desde un equipo sin GPU:
- Arquitectura y las **8 tareas del motor** de Terra (RunSFM, Reconstruct2D/3D/3DGS,
  LidarPostProcessing, GCPPreview/ImagePreview, GenerateModifyFiles, HealthCheck) — `spec/01`,`spec/04`.
- **Formatos**: modelo de datos JSON/XML + formatos abiertos (PLY/LAS/LAZ/PCD/GeoTIFF/OBJ/
  OSGB/I3S/S3M/3D-Tiles/3MX) — `spec/02`. **Coordenadas** (GDAL/OGR, EGM2008) — `spec/03`.
- **IA/3DGS**: CUDA nativo + modelo cifrado — `spec/05`. **Modify**: Electron/Vue/Cesium — `spec/06`.
- Núcleo nativo cifrado/compilado: decompilación pendiente — `spec/07`.

## Ayuda buscada: colaboradores con GPU NVIDIA
La parte de **ejecución** (procesar un dataset real y capturar los formatos exactos) no se
pudo hacer sin GPU CUDA. Si tienes una PC capaz, sigue **`spec/08-runtime.md`** y
**`CONTRIBUTING.md`** — es una tarea autónoma que desbloquea el 100% de los formatos.
