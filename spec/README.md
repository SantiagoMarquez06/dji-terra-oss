# terra-spec — Especificación de comportamiento de DJI Terra (clean-room)

Documentación derivada por ingeniería inversa de DJI Terra 5.3.5 para construir una
alternativa libre interoperable (`terra-oss`). Aquí NO va código de DJI: solo
especificaciones de comportamiento (entradas → transformación → salidas).

Convención de evidencia en cada afirmación:
- `[COMPROBADO: <Evidence ID / archivo>]` — observado directamente.
- `[SUPUESTO: <razón>]` — inferencia, aún sin confirmar.

## Índice
- 01-arquitectura.md — mapa de módulos y lenguajes
- 02-formatos.md — bases de datos y formatos de proyecto/salida
- 03-coordenadas.md — sistema de coordenadas
- 04-pipeline.md — etapas y parámetros del procesamiento
- 05-ia.md — 3D Gaussian Splatting y clasificación semántica
- 06-modify.md — app Electron DJI Modify
- 07-nativo.md — motor nativo C++ (Fast*/Terra*)
- 08-runtime.md — observación en ejecución (diferido)
