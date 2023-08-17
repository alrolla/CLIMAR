# CLIMAR
## Resumen
<p align="justify" >
El proyecto CLIMAR se basa en el desarrollo de herramientas de monitoreo y pronóstico climático en escalas sub-estacional (semanas) y estacional (meses).        
</p>

## Procesamiento Geopotencial en 200 hPa ( Z200)
crontab
0 4 * * * /home/alrolla/Prono_Semanal/z200/scripts/CFSProc_z200.sh

* Realiza la descarga de los archivos de CFS  horarios de Z200
* Calculo la anomalia con respecto a la climatologia
* Genero analisis Diario
* Genero analisis Ultima semana y anomalia respecto de la climatologia semanal para este dia
* Realiza proceso de generacion de los mapas
* Georeferencio los mapas
* Inserto el registro en la DB y copio los mapas.

## Procesamiento OLR

crontab
30 4 * * * /home/alrolla/Prono_Semanal/olr/scripts/CFSProc_olr.sh

* Realiza la descarga de los archivos de CFS horarios de OLR
* Calculo la anomalia con respecto a la climatologia
* Genero analisis Diario
* Genero analisis Ultima semana y anomalia respecto de la climatologia semanal para este dia
* Realiza proceso de generacion de los mapas
* Georeferencio los mapas
* Inserto el registro en la DB y copio los mapas.

