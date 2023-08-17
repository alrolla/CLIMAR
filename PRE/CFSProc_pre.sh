n/bash

if [ "$#" -eq 0 ];then
	#calculo la fecha de dos dias antes
	Fecha=`date +%Y%m%d -d '1 days ago'`
else
    #Proceso la fecha informada en la linea de comandos
	Fecha=$1
fi
echo "procesando $Fecha"

#Path Base
PBase=/home/alrolla/Prono_Semanal/pre
PBaseproba=/home/alrolla/Prono_Semanal/pre.proba/scripts
#Path to scripts
PScript=${PBase}/scripts

#Path to logs
PLogs=${PBase}/scripts/logs

#Path to destino de datos
PSave=/datos/Prono_Semanal/pre/Data

#Path to climatologies
dClima=/datos/Prono_Semanal/pre/Data/Climatologia/
#Path to R programs
rProg=/home/alrolla/Prono_Semanal/pre/scripts/

#Path to gdal utilities
gdal=/usr/bin

#Path to imagemagick utilities
imagemagick=/usr/bin

#Path to imagemagick utilities
grads=/opt/opengrads

export PATH=$PATH:/usr/local/wgrib2/
export http_proxy=http://proxy.uba.ar:8080

#Path to anomalies
dAnom=/datos/Prono_Semanal/pre/Data/D${Fecha}/

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
      for var in prate 
        do
	      file=${URLftp}time_grib_${serie}/${var}.${serie}.${Fecha}${hora}.daily.grb2
	      /usr/bin/wget  -c --tries=0  ${file} -o /datos/Prono_Semanal/pre/logs/CFSWeek.log
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
for var in  prate
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
          /usr/bin/ncks -d time,0,44 ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean.nc  ./Diario/${var}.${serie}.${Fecha}${hora}.dailymean45d.nc
          
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
# #for var in  tmp2m tmax tmin ulwtoa prate dswsfc z200
for var in  prate
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
#ncks --mk_rec_dmn time pre_0327S.nc pre_0327S.nc 
# habra que hacerlo en toda la climatologia :-)
ncks -O --mk_rec_dmn time ${dClima}precipitation_${Fecha:4:4}_S.nc ${dClima}precipitation_${Fecha:4:4}_S.nc

#calculo el promedio semanal de las proximas 4 semanas de la climatologia para ese dia
ncra -O -F -d time,1,7,1    ${dClima}precipitation_${Fecha:4:4}_S.nc pre_cli${Fecha:4:4}.week1mean.nc
ncra -O -F -d time,8,14,1   ${dClima}precipitation_${Fecha:4:4}_S.nc pre_cli${Fecha:4:4}.week2mean.nc
ncra -O -F -d time,15,21,1  ${dClima}precipitation_${Fecha:4:4}_S.nc pre_cli${Fecha:4:4}.week3mean.nc
ncra -O -F -d time,22,28,1  ${dClima}precipitation_${Fecha:4:4}_S.nc pre_cli${Fecha:4:4}.week4mean.nc


# Calculo la anomalia con respecto a la climatologia
/usr/bin/Rscript ${rProg}AnomaliasCFS.r "${Fecha}" "pre" "precipitation" "mm day-1" "prate" "pre_cli" "PRATE_surface"


mkdir mapas

#Genero las imagenes de precipitacion
echo "Proceso de generacion de los mapas"

${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} pre 1" > /dev/null

echo "${grads}/grads -a 1.680169 -b -l -c 'run  ${rProg}plotPronoWeekly.gs ${Fecha} pre 1' "
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} pre 2" > /dev/null
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} pre 3" > /dev/null
${grads}/grads -a 1.680169 -b -l -c "run  ${rProg}plotPronoWeekly.gs ${Fecha} pre 4" > /dev/null


cd mapas

for semana in 1  2 3 4
do

#Esto georeferencia la imagen
$gdal/gdal_translate -of PNG -a_srs EPSG:4326 -a_ullr -100. 20.  -20. -80.0 anom.pre.${Fecha}.week${semana}.jpg anom.pre.${Fecha}.week${semana}.png 

#Esto aplica la proyeccion y genera un geotiff
$gdal/gdalwarp -t_srs '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs' anom.pre.${Fecha}.week${semana}.png anom.pre.${Fecha}.week${semana}.tiff

#Esto transforma la imagen en PNG
$gdal/gdal_translate -of PNG  anom.pre.${Fecha}.week${semana}.tiff anom.pre.${Fecha}.week${semana}f.png

#Esto elimina el color blanco de la imagen
${imagemagick}/convert anom.pre.${Fecha}.week${semana}f.png -fuzz 10% -transparent white anom.pre.${Fecha}.week${semana}f.png


rm anom.pre.${Fecha}.week${semana}*.jpg
rm anom.pre.${Fecha}.week${semana}.png
rm anom.pre.${Fecha}.week${semana}*.xml
rm anom.pre.${Fecha}.week${semana}*.tiff

done

# check file creation

ultfile=anom.pre.${Fecha}.week${semana}f.png
sizfile=$(du -k "$ultfile" | cut -f 1)
minsize=100

if [ $sizfile -ge $minsize ]
then

    # En caso que el proceso termino bien inserto el registro en la DB y copio los mapas.
    
	/usr/bin/php -f $rProg/chkFinal.php anom.pre.${Fecha}.week${semana}f.png pre
	cp *f.png /var/www/html/CFS/mapas/pre/
     echo ""
	 echo "Final exitoso !!!!!!!!!"
	 echo "Final exitoso !!!!!!!!!"
	 echo "Final exitoso !!!!!!!!!"
	 $PBaseproba/CFSProc_pre.sh $Fecha
else
     echo ""
     echo ""
     echo ""
	 echo "ARCHIVO: $ultfile .... No encontrado!!!!!. Final del proceso erroneo"

fi

#FINALE DE PRECIPITACION
