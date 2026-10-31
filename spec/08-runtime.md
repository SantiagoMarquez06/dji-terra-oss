# 08 — Captura en ejecución (para colaborador con GPU NVIDIA)

Esta parte NO se puede hacer en el equipo de desarrollo original (sin GPU CUDA). Es una
tarea autónoma para cualquiera con hardware capaz. Produce la evidencia que cierra los
formatos y el comportamiento reales al 100%.

## Requisitos
- Windows 10/11, **GPU NVIDIA con CUDA** (driver reciente), 32 GB RAM recomendado, ~30 GB libres.
- DJI Terra instalado (versión de prueba o con licencia; funciones básicas valen).
- Un set de imágenes de dron público, p. ej.:
  - OpenDroneMap sample datasets: https://github.com/OpenDroneMap/odm_data_aukerman (y otros en esa org).
  - Cualquier vuelo propio con solape ≥70%.

## Qué necesitamos (lo pequeño y valioso)
Los **archivos JSON/XML/log** que Terra crea en la carpeta del proyecto. NO hacen falta las
nubes/mallas grandes (.ply/.las/.osgb) para documentar formatos. Son datos generados de
TUS imágenes: describen la estructura, no contienen nada de DJI.

## Pasos
1. Crear un proyecto en Terra y procesar, idealmente, cada tipo: **2D (mapa)**, **3D**,
   **LiDAR** (si hay) y **3DGS**. Marcar algún GCP para generar los `gcp_*.json`.
2. Al terminar, localizar la carpeta del proyecto (Terra la crea en `Documents/DJI/DJI Terra`
   o donde se elija).
3. Ejecutar `tools/collect_terra_evidence.ps1` (en este repo) apuntando a esa carpeta: recoge
   todos los JSON/XML/log y un árbol de archivos, en un zip pequeño.
4. (Opcional, avanzado) Grabar con **Process Monitor** (Sysinternals) filtrando por
   `DJIMapGen.exe`/`TerraWorkingProcess.exe` para ver orden de etapas, archivos y red; y con
   **Wireshark** el tráfico, para documentar qué va a la nube de DJI.
5. Subir el zip como adjunto en un issue del repo, o PR a `evidence-runtime/`.

## Qué haremos con eso
Convertir cada JSON/XML en su **esquema** dentro de `02-formatos.md` y confirmar el pipeline
de `04-pipeline.md`, cerrando las partes marcadas como [SUPUESTO].
