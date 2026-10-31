# 07 — Motor nativo C++ (Fast*/Terra*) — pendiente de decompilación profunda

[Estado: identificado estáticamente; la decompilación con Ghidra queda pendiente —requiere
más cómputo que el equipo original (i3/12 GB, sin GPU). Es una buena tarea de colaborador.]

## Objetivos de decompilación (por prioridad de interés)
1. **TerraSDK.dll** (67 MB) — escribe/lee los JSON del `02-formatos.md`. Decompilar las
   funciones de serialización daría el **esquema exacto** de `sfm_geo_desc.json`,
   `camera_info.json`, `at_data.json`, `parameter.json`, `task.json`, `gcp_*.json`.
   (Alternativa más barata: obtener esos JSON de una muestra real — ver `08-runtime.md`.)
2. **TerraCoordinateSystemSDK.dll** (2.2 MB, ligero) — transformación CS local ENU ↔ CRS,
   geoide, UTM. Decompilable incluso en hardware modesto.
3. **FastSFM / FastSGM / FastPM / FastFuse / FastDsmBuild** — algoritmos del pipeline denso;
   solo si `terra-oss` necesita algo que COLMAP/OpenMVS no cubran.
4. **dInfer/dGraph** — extractor/emparejador de rasgos neuronal (API `..._feature_*_proxy`).
5. **main.node** (DJI Modify) — API del motor de edición (FFI koffi) y formato `.dmep`.

## Recomendación
Preferir **muestras reales** (`08-runtime.md`) para los formatos; reservar Ghidra para lo
que las muestras no revelen (parámetros internos, matemática exacta de una etapa).
Al abrir con REA/Ghidra: trabajar por función, resumen primero, y podar la base de datos de
Ghidra tras cada DLL para no llenar el disco.
