# 03 — Sistema de coordenadas

Fuente: cadenas de `TerraCoordinateSystemSDK.dll` y `TerraSDK.dll`
(`app/Assistant/map_gen/`). [COMPROBADO: scan de cadenas, 2026-10-30]

## Base: GDAL/OGR
Terra apoya toda su geodesia en **OGR `OGRSpatialReference`** (se ven los símbolos
`importFromEPSG`, `SetProjCS`, `SetWellKnownGeogCS`, `IsProjected`, `GEOGCS`, `PROJCS`).
→ Maneja EPSG/WKT estándar. **terra-oss usa GDAL/PROJ directamente y queda compatible.**

## CRS observados
- **EPSG:4326** — WGS84 geográfico (lat/lon). CRS de referencia principal.
- **EPSG:3857** — Web Mercator (teselas de mapa base).
- **EPSG:4978** — ECEF geocéntrico (usado para 3D/registro global).
- **EPSG:5737** — altura (vertical), coherente con geoide EGM2008.
- **UTM** — zona automática ("UTM CODE:", "wrap UTM image"), vía Transverse Mercator.
- **CGCS2000 / GCJ-02** — datum chino y ofuscación GCJ (`use_gcj02`, "GCJ tiles") solo
  para teselas de mapa base en China.

## Datum vertical y geoide
- `VERT_DATUM`, `GeoidFileName`/`geoid_file_name`, `contour_datum`.
- Geoide por defecto: **`us_nga_egm08_25.tif`** = EGM2008 a 2.5′ (dato **público** de la NGA).
- `height_transformer.json` guarda la transformación de alturas.
- Aviso interno: "down sampled dsm will not convert to WGS84" (el DSM reescalado se queda en CS local).

## CS local y registro geográfico
- **`LOCAL_ENU_CS`** — plano tangente local Este-Norte-Arriba; la reconstrucción se hace
  en coordenadas locales y luego se transforma a UTM/geográficas.
- "coordinate transfer definition which used to transfer point from local CS to UTM".
- Archivos que describen el registro local↔geográfico:
  `sfm_geo_desc.json`, `geo_desc.json`, `lidar_geo_desc.json`, `geographic_division.json`.

## Implicación para terra-oss
- Reutilizar GDAL/PROJ + geoide EGM2008/EGM96 públicos → paridad geodésica sin datos de DJI.
- El puente de interoperabilidad es el `*_geo_desc.json` (transformación CS local → CRS
  geográfico). Documentar su esquema es prioritario (pendiente: ver muestra real o el
  código que lo escribe en TerraSDK). [SUPUESTO: contiene origen ENU + EPSG destino + geoide]
