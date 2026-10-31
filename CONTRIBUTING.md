# Cómo contribuir

Este repo documenta el **comportamiento** de DJI Terra para construir una alternativa libre
interoperable (`terra-oss`). Trabajo *clean-room*: aquí solo van especificaciones y evidencia
generada por el propio colaborador; **nunca** binarios, modelos ni datos de DJI.

## Se busca especialmente
Colaboradores con **PC con GPU NVIDIA** que puedan ejecutar DJI Terra y aportar la evidencia
de formatos siguiendo `08-runtime.md` (script en `tools/collect_terra_evidence.ps1`). El
equipo original de análisis no tiene GPU, así que esta pieza está bloqueada sin tu ayuda.

## Reglas
- No subas ejecutables, DLL, `.enc`, `.db` ni modelos de DJI. Solo JSON/XML/log/esquemas.
- Marca cada afirmación como `[COMPROBADO: fuente]` o `[SUPUESTO: razón]`.
- No se tratan licencia/activación (CodeMeter) ni ataques a servidores de DJI.
