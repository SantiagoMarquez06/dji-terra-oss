# 06 — DJI Modify (app Electron)

[COMPROBADO: extracción de `app/Appfiles/app.asar` (1414 entradas) y lectura del
renderer, 2026-10-30]. `name: pc-model-editor-fe` ("point cloud model editor").

## Arquitectura
- **Electron**. `main.js` (42 bytes) solo hace `require('./main.node').default(require)`:
  todo el proceso principal vive en **`main.node`** (addon C++ nativo).
- **`background.js`** (714 KB) está **cifrado** (entropía 6.0, base64 de ciphertext);
  lo descifra `main.node` en ejecución. → la lógica del proceso principal está protegida.
- Dependencias Node: `koffi` (FFI a C), `jschardet`, `bytes`, `@sentry/electron`.
  → el motor se invoca por **FFI/addon nativo**, no lanzando un `.exe`.
- **Renderer = Vue** (`js/app.*.js` 3.1 MB + `js/chunk-vendors.*.js` 11.6 MB), **legible**
  (minificado, no cifrado). Contiene toda la UI y el conjunto de funciones.
- **Visor 3D = CesiumJS**, renombrado "Maple" (`static/Maple/…`: `IAU2006_XYS`,
  `approximateTerrainHeights.json`, `google-earth-dbroot-parser.js`, Workers de Cesium).

## Formatos (del renderer)
- Proyecto propio: **`.dmep`** (`APP_PROJECT_FILE_EXTENSION = "dmep"`).
- Importa/exporta: `.las`/`.laz`, `.ply`, `.pcd`, `.obj`, `.glb`, `.osgb`, `.b3dm`, `.fbx`,
  `.xml`, `.json`; imágenes `.jpg/.jpeg/.heic`; `.txt/.csv`; informes `.pdf`.
- Coherente con las salidas de Terra: Modify consume las mallas/nubes/3D-tiles que Terra genera.

## Implicación para terra-oss
- La UI (Vue + Cesium) es **reconstruible con tecnología libre**: Vue + CesiumJS (open source).
- Formatos de E/S: todos estándar salvo `.dmep` (documentar su esquema; es un proyecto de
  edición de nube/modelo). Pendiente: muestra real de `.dmep` o Ghidra sobre `main.node`.
- El motor de edición (en `main.node`, C++) queda para Fase 6 si hace falta; la mayoría de
  operaciones de edición de nubes/mallas existen en PDAL/CloudCompare/Open3D libres.

## Patrón común de los 3 programas (meta-hallazgo)
DJI deja **legibles la orquestación, la UI y los formatos** (JSON/XML/estándar), pero
**protege el núcleo**: motores en C++/CUDA nativo y recursos cifrados (`background.js`,
`ai_fm.*.enc`, las `.db`). → La interoperabilidad (objetivo del proyecto) es muy viable;
clonar los algoritmos internos exactos no, pero no hace falta (hay equivalentes libres).
