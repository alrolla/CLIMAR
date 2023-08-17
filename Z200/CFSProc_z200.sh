#!/bin/bash

Programa para procesamiento de los archivos de 200 hPa (z200)

if [ "$#" -eq 0 ];then
	#calculo la fecha de dos dias antes
	Fecha=`date +%Y%m%d -d '1 days ago'`
else
    #Proceso la fecha informada en la linea de comandos
	Fecha=$1
fi
echo "procesando $Fecha"

#Path Base
PBase=/home/alrolla/Prono_Semanal/z200

#Path to scripts
PScript=${PBase}/scripts

#Path to logs
PLogs=${PBase}/scripts/logs

#Path to destino de datos
PSave=/datos/Prono_Semanal/z200/Data

#Path to climatologies
dClima=/datos/Prono_Semanal/z200/Data/Climatologia/
#Path to R programs
rProg=/home/alrolla/Prono_Semanal/z200/scripts/

#Path to gdal utilities
gdal=/usr/bin

#Path to imagemagick utilities
imagemagick=/usr/bin

#Path to imagemagick utilities
grads=/opt/opengrads

export PATH=$PATH:/usr/local/wgrib2/
export http_proxy=http://proxy.fcen.uba.ar:8080

#Path to anomalies
dAnom=/datos/Prono_Semanal/z200/Data/D${Fecha}/

# Configuracion http

#cambio al directorio de salida y empiezo a descargar los archivos
cd $PSave
mkdir D${Fecha}
cd D${Fecha}

#Descargo las variables

for hora in 00 06 12 18
do

  URLftp=http://www.ftp.ncep.noaa.gov/data/nccf/com/cfs/prod/cfs.${Fecha}/${hora}/

  for serie in 01 02 03 04
    do
      #for var in  tmp2m tmax tmin ulwtoa prate dswsfc z200
      for var in z200 
        do
	      file=${URLftp}time_grib_${serie}/${var}.${serie}.${Fecha}${hora}.daily.grb2
	      /usr/bin/wget  -c --tries=0  ${file} -o /datos/Prono_Semanal/z200/logs/CFSWeek.log
         
        done #fin var
    done #fin serie

done #fin Hora




#Chequear que termino bien la descarga , avisar! y sino no hacer nada ( no seguir el script )
# quizas mostrar el problema o avisar del problema con un mail a los interesados
#???

#Procesar los archivos
#generar los campos medios diarios desde los horarios
#
mkdir Diario

echo "Proceso de generacion de los archivos diarios"
#for var in  tmp2m tmax tmin ulwtoa prate dswsfc z200
for var in  z200
do
	for hora in 00 06 12 18
	do
  		for serie in 01 02 03 04
		do
		  
		  #Convierto los grib2 en netcdf para facilidad de procesamiento los archivos seran mas grandes)
	      /usr/local/bin/wgrib2 ${var}.${serie}.${Fecha}${hora}.daily.grb2 -netcdf ${var}.${serie}.${Fecha}${hora}.daily.nc #>& /dev/null
	      
	      #Calculo la media diaria
	      /usr/bin/cdo daymean ${var}.${serie}.${Fecha}${hora}.daily.nc ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean.nc 
          
          #Recorto los archivos para que tengan 42 dias , para poder hacer el ensamble ( si los tiempos no coindciden NO hay ensamble)
          #ya que solo se necesitan 4 semanas ( 4x7=28 dias) ;-) , si se necesitan mas dias hasta 6 semanas se puede seguir con esto.
          ncks -d time,0,44 ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean.nc  ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean45d.nc
          
          #Borro los archivos temporarios
          rm ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean.nc
          rm ${var}.${serie}.${Fecha}${hora}.daily.nc
          
    	done #fin serie
	done #fin Hora
done #fin var


cd Diario

mkdir EnsDiario
#Procesar los 16 miembros de cada variable y calcula el ensamble medio

echo "Proceso de generacion de los ensambles"

files=""
  #for var in  tmp2m tmax tmin ulwtoa prate dswsfc z200
for var in  z200
do
    m=1
	for hora in 00 06 12 18
	do
  		for serie in 01 02 03 04
    	do
	      mm=$(printf "%02d" $m )
          files=$files" "${var}.${serie}.${Fecha}${hora}.dailymean45d_m${mm}.nc   
          
          cp ${var}.${serie}.${Fecha}${hora}.dailymean45d.nc ./EnsDiario/${var}.${serie}.${Fecha}${hora}.dailymean45d_m${mm}.nc
          
          let m="$m+1"
          
    	done #fin serie
	done #fin Hora
	cd EnsDiario
		#Genero el ensamble medio diario
		echo $files
		/usr/bin/cdo ensmean $files ${var}.${Fecha}.daily.ensmean.nc
		#Genero los campos medios semanales desde el ensamble medio diario 
		ncra -F -d time,1,7,1  ${var}.${Fecha}.daily.ensmean.nc ${var}.${Fecha}.week1mean.nc
		ncra -F -d time,8,14,1  ${var}.${Fecha}.daily.ensmean.nc ${var}.${Fecha}.week2mean.nc
		ncra -F -d time,15,21,1  ${var}.${Fecha}.daily.ensmean.nc ${var}.${Fecha}.week3mean.nc
		ncra -F -d time,22,28,1  ${var}.${Fecha}.daily.ensmean.nc ${var}.${Fecha}.week4mean.nc
	cd ..
done #fin var

# Muevo y borro los temporales y dejo todo acomodado para calcular anomalias y generacion de mapas

mv EnsDiario ..
cd ..
rm -fr Diario
rm -f *.grb2
mv EnsDiario/* .
rmdir EnsDiario

#PROCESO PRECIPITACION

cd ${dAnom}

#Esto setea la dimension time como record dimension ( me olvide de hacerlo en el programa R)
##ncks --mk_rec_dmn time pre_0327S.nc pre_0327S.nc 
# habra que hacerlo en toda la climatologia :-)

ncks -O --mk_rec_dmn time ${dClima}z200_${Fecha:4:4}_S.nc ${dClima}z200_${Fecha:4:4}_S.nc

#calculo el promedio semanal de las proximas 4 semanas de la climatologia para ese dia
ncra -O -F -d time,1,7,1    ${dClima}z200_${Fecha:4:4}_S.nc z200_cli${Fecha:4:4}.week1mean.nc
ncra -O -F -d time,8,14,1   ${dClima}z200_${Fecha:4:4}_S.nc z200_cli${Fecha:4:4}.week2mean.nc
ncra -O -F -d time,15,21,1  ${dClima}z200_${Fecha:4:4}_S.nc z200_cli${Fecha:4:4}.week3mean.nc
ncra -O -F -d time,22,28,1  ${dClima}z200_${Fecha:4:4}_S.nc z200_cli${Fecha:4:4}.week4mean.nc



# Calculo la anomalia con respecto a la climatologia
echo "Calculo la anomalia con respecto a la climatologia"
echo "/usr/bin/Rscript ${rProg}AnomaliasCFS.r "${Fecha}" "z200" "geopotencial_200" "m" "z200" "z200_cli" "HGT_200mb""


/usr/bin/Rscript ${rProg}AnomaliasCFS.r "${Fecha}" "z200" "geopotencial_200" "m" "z200" "z200_cli" "HGT_200mb"


#Genero analisis Diario
echo "Genero analisis Diario"
/usr/bin/Rscript ${rProg}analisis_diario.R "${Fecha}" 

#Genero analisis Ultima semana y anomalia respecto de la climatologia semanal para este dia
echo "Genero analisis Ultima semana y anomalia respecto de la climatologia semanal para este dia"

/usr/bin/Rscript ${rProg}analisis_semanal.R "${Fecha}" 


mkdir mapas

#Genero las imagenes de precipitacion
echo "Proceso de generacion de los mapas"

${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} z200 1" > /dev/null

echo "${grads}/grads -a 1.680169 -b -l -c 'run  ${rProg}plotPronoWeekly.gs ${Fecha} z200 1' "

${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} z200 2" > /dev/null
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} z200 3" > /dev/null
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} z200 4" > /dev/null


#Analisis - genero y georeferencio los mapas
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotAnalisisWeekly.gs ${Fecha} " > /dev/null

cd mapas

for semana in 1  2 3 4
do

#Esto georeferencia la imagen
$gdal/gdal_translate -of PNG -a_srs EPSG:4326 -a_ullr 0. 40.  360. -80.0 anom.z200.${Fecha}.week${semana}.jpg anom.z200.${Fecha}.week${semana}.png 
#echo $gdal/gdal_translate -of PNG -a_srs EPSG:4326 -a_ullr 0. 40.  360. -80.0 anom.z200.${Fecha}.week${semana}.jpg anom.z200.${Fecha}.week${semana}.png 

#Esto aplica la proyeccion y genera un geotiff
$gdal/gdalwarp   -t_srs '+proj=merc +pm=180  +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs' anom.z200.${Fecha}.week${semana}.png anom.z200.${Fecha}.week${semana}.tiff  
#echo $gdal/gdalwarp   -t_srs '+proj=merc +pm=-180 +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs' anom.z200.${Fecha}.week${semana}.png anom.z200.${Fecha}.week${semana}.gtiff  

#Esto transforma la imagen en PNG
$gdal/gdal_translate -of PNG  anom.z200.${Fecha}.week${semana}.tiff anom.z200.${Fecha}.week${semana}f.png

#Esto elimina el color blanco de la imagen
${imagemagick}/convert anom.z200.${Fecha}.week${semana}f.png -fuzz 2% -transparent white anom.z200.${Fecha}.week${semana}f.png

rm anom.z200.${Fecha}.week${semana}*.jpg
rm anom.z200.${Fecha}.week${semana}.png
rm anom.z200.${Fecha}.week${semana}*.xml
rm anom.z200.${Fecha}.week${semana}*.tiff

done


#Analisis Esto georeferencia la imagen
$gdal/gdal_translate -of PNG -a_srs EPSG:4326 -a_ullr 0. 40.  360. -80.0 anom.z200.${Fecha}.analisis.jpg  anom.z200.${Fecha}.analisis.png 
#echo $gdal/gdal_translate -of PNG -a_srs EPSG:4326 -a_ullr 0. 40.  360. -80.0 anom.z200.${Fecha}.week${semana}.jpg anom.z200.${Fecha}.week${semana}.png 

#Esto aplica la proyeccion y genera un geotiff
$gdal/gdalwarp   -t_srs '+proj=merc +pm=180  +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs' anom.z200.${Fecha}.analisis.png  anom.z200.${Fecha}.analisis.tiff  
#echo $gdal/gdalwarp   -t_srs '+proj=merc +pm=-180 +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs' anom.z200.${Fecha}.week${semana}.png anom.z200.${Fecha}.week${semana}.gtiff  

#Esto transforma la imagen en PNG
$gdal/gdal_translate -of PNG  anom.z200.${Fecha}.analisis.tiff anom.z200.${Fecha}.analisisf.png

#Esto elimina el color blanco de la imagen
${imagemagick}/convert anom.z200.${Fecha}.analisisf.png -fuzz 2% -transparent white anom.z200.${Fecha}.analisisf.png

rm anom.z200.${Fecha}*.jpg
rm anom.z200.${Fecha}.analisis.png
rm anom.z200.${Fecha}.analisis*.xml
rm anom.z200.${Fecha}.analisis*.tiff

# check file creation
ultfile=anom.z200.${Fecha}.analisisf.png
sizfile=$(du -k "$ultfile" | cut -f 1)
minsize=100

if [ $sizfile -ge $minsize ]
then

    # En caso que el proceso termino bien inserto el registro en la DB y copio los mapas.
    
	/usr/bin/php -f $rProg/chkFinal.php anom.z200.${Fecha}.week${semana}f.png z200
	/usr/bin/php -f $rProg/chkFinal.php anom.z200.${Fecha}.week${semana}f.png z200a
	
	cp *f.png /var/www/html/CFS/mapas/z200/
     echo ""
	 echo "Final exitoso !!!!!!!!!"
	 echo "Final exitoso !!!!!!!!!"
	 echo "Final exitoso !!!!!!!!!"
else
     echo ""
     echo ""
     echo ""
	 echo "ARCHIVO: $ultfile .... No encontrado!!!!!. Final del proceso erroneo"

fi

#FINALE DE PRECIPITACION

