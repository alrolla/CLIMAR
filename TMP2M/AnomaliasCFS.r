 library("ncdf4")

setwd(".")

args <- commandArgs(trailingOnly = TRUE)
 

fechac    <- args[1] #"20150327"
varname   <- args[2] #"tmp2m"
varnamel  <- args[3] #"temperatura"
unitsx    <- args[4] #"K"
namein1   <- args[5] # "tmp2m"
namein2   <- args[6] # "t2m"
varnProno <- args[7] # "TMP_2maboveground"


fecha     <- paste(substr(fechac,1,4),"-",substr(fechac,5,6),"-",substr(fechac,7,8),sep="")

print(fecha)

fechaMD <-substr(fechac,5,8)

print(fechaMD)
for (m in seq(1,16,1)){
for(iw in c(1,2,3,4)){

	fProno <- paste(namein1,".",fechac,".week",iw,"mean.nc",sep="")
	varnProno <- varnProno
	
	fClima <- paste(namein2,fechaMD,".week",iw,"mean.nc",sep="")
	varnClima <- paste(varname,fechaMD,"s",sep="")
	
	varLat <- "latitude"
	varLon <- "longitude"
	
	ncProno <- nc_open(fProno)
	varProno <- ncvar_get(ncProno,varnProno)
	varProno <- varProno
	
	vlat <- ncvar_get(ncProno,"latitude")
	vlon <- ncvar_get(ncProno,"longitude")
	
	ncClima <- nc_open(fClima)
	varClima <- ncvar_get(ncClima,varnClima)
	
	varDif <- array(NA, dim=c(384,190))
	
	varDif <- varProno - varClima
	
	#image.plot(varDif)



	#create the output file with the daily raw data global
	dimTime <- ncdim_def('time', unlim=TRUE,units=paste('days since ',fecha,' 00:00.00',sep=''), longname='time', calendar="standard", vals=7*(iw-1)+1)
	dimLat <- ncdim_def('lat', units='degrees_north', longname='latitude', vals=vlat)
	dimLon <- ncdim_def('lon', units='degrees_east', longname='longitude', vals=vlon)
	
	varx <- ncvar_def(name=varname, units=unitsx, dim=list(dimLon,dimLat,dimTime), missval=-9999, longname=varnamel)
	
	outputfile <- paste('anom.',varname,'.',fechac,'.week',iw,'.nc',sep='')
	
	con <- nc_create(outputfile, varx)
	
	ncatt_put(con, 'lat', 'standard_name', 'latitude')
	ncatt_put(con, 'lon', 'standard_name', 'longitude')
	ncatt_put(con, varx, 'standard_name',varname)
	
	ncatt_put(con, 'time', 'standard_name', 'time')
	ncatt_put(con, 'lon', 'axis', 'X')
	ncatt_put(con, 'lat', 'axis', 'Y')
	ncatt_put(con, 'time', 'axis', 'T')
	
	ncvar_put(con, varx, varDif)
	
	nc_close(con)
	
	#Sys.sleep(3)
	print(paste('procesando week',iw))

}
}
print('fin proceso')
