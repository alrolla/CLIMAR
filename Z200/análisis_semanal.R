library(ncdf4)
#library(ramify)

#Calculo de analisis medio de los ultimos 7 dias

setwd(".")

args <- commandArgs(trailingOnly = TRUE)

fecha = args[1] #"20170523"
#fecha = "20170523"
month=substr(fecha,5,6)
day=substr(fecha,7,8)

fecha.d=paste(substr(fecha,1,4),"-",substr(fecha,5,6),"-",substr(fecha,7,8),sep="")

fecha.i=as.Date(fecha.d)-6

print(fecha.i)
print(getwd())

fechas=seq(fecha.i,fecha.i+6,by="days")
dirbase="/datos/Prono_Semanal/z200/Data/"

varZ200 <- array(NA, dim=c(360,181,7))

it=0
for( i in 1:length(fechas)){
  fechax=as.character(fechas[i])
  fecha.c=paste(substr(fechax,1,4),substr(fechax,6,7),substr(fechax,9,10),sep="")
  fz200=paste(dirbase,"D",fecha.c,"/z200.",fecha.c,".daily.AN.nc",sep="")
  if(file.exists(fz200)){
    nc = nc_open(fz200)
  	var = ncvar_get(nc,"z200")
  	lat = ncvar_get(nc,"lat")
  	lon = ncvar_get(nc,"lon")
  	it=it+1
  	varZ200[,,it]=var
  	print(paste0("varZ200[50,50,it]: ",varZ200[50,50,it]))
  	nc_close(nc)    
  }else{
	   print(paste("archivo NO existe",fz200))
  }

}

varZ200mean <- array(NA, dim=c(360,181))



seriew=(is.na(varZ200[50,50,]))


nitx=as.integer(length(which(seriew == FALSE)))

#print(paste0("ntx: ", nitx))


if(nitx == 1){
    itm=which(!is.na(varZ200[50,50,]))
#    print(paste0("itm: ",itm))
    varZ200mean = varZ200[,,itm]
#    print(class(varZ200mean))
#   resize(varZ200mean,360,181)
#    print(dim(varZ200mean))
#    print(varZ200mean[50,50])
    
}else{
     varZ200mean=rowMeans( varZ200[,,1:it] ,dims=2,na.rm=TRUE) 
}


# varZ200mean <- rowMeans( varZ200[,,1:it] ,dims=2,na.rm=TRUE) 




dimLon <- ncdim_def('lon', units='degrees_east', longname='lon', vals=lon)
dimLat <- ncdim_def('lat', units='degrees_north', longname='lat', vals=lat)
dimTime <- ncdim_def('time', units=paste('days since 1970-',month,'-',day,' 00:00.00',sep=''), longname='time', calendar="standard", vals=c(0))

#definicion de las variables
var <- ncvar_def(name='z200', units='m', dim=list(dimLon,dimLat,dimTime),compression=1, missval=-9999, longname=paste('z200',month,day," daily analysis",sep=""))
fz200.week=paste(dirbase,"/D",fecha,"/z200.",fecha,".weekly.AN.nc",sep="")
nc_o <- nc_create(fz200.week,var)

ncvar_put(nc_o, var,varZ200mean)

nc_close(nc_o)

dirbasea="/datos/Prono_Semanal/z200/Data/Analisis/"

fn.z200.clim=paste(dirbasea,"z200_",month,day,"_AN_7d.nc",sep="")
nc = nc_open(fn.z200.clim)
z200.clim = ncvar_get(nc,paste("z200",month,day,sep=""))
lat = ncvar_get(nc,"lat")
lon = ncvar_get(nc,"lon")
#print(z200.clim[50,50])

z200.anom=varZ200mean-z200.clim

dimLon <- ncdim_def('lon', units='degrees_east', longname='lon', vals=lon)
dimLat <- ncdim_def('lat', units='degrees_north', longname='lat', vals=lat)
dimTime <- ncdim_def('time', units=paste('days since 1970-',month,'-',day,' 00:00.00',sep=''), longname='time', calendar="standard", vals=c(0))

#definicion de las variables
var <- ncvar_def(name='z200', units='m', dim=list(dimLon,dimLat,dimTime),compression=1, missval=-9999, longname=paste('z200',month,day," weekly anomaly",sep=""))
fz200.anom=paste(dirbase,"/D",fecha,"/z200.",fecha,".anom.AN.nc",sep="")
nc_a <- nc_create(fz200.anom,var)

ncvar_put(nc_a, var,z200.anom)



print(z200.anom[50,50])
nc_close(nc_a)




