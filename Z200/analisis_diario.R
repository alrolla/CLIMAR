# Genera analisis diario

library(ncdf4)

setwd(".")

args <- commandArgs(trailingOnly = TRUE)

fecha = args[1] #"20170523"
#fecha = "20170523"
month=substr(fecha,5,6)
day=substr(fecha,7,8)

#calculo del promedio diario

fname1=paste("z200.01.",fecha,"00.dailymean45d_m01.nc",sep="")
fname2=paste("z200.01.",fecha,"06.dailymean45d_m05.nc",sep="")
fname3=paste("z200.01.",fecha,"12.dailymean45d_m09.nc",sep="")
fname4=paste("z200.01.",fecha,"18.dailymean45d_m13.nc",sep="")

fnames=c(fname1,fname2,fname3,fname4)

varZ200 <- array(NA, dim=c(360,181,4))

it=1
for (f in fnames){
  nc = nc_open(f)
  var = ncvar_get(nc,"HGT_200mb")
  lat = ncvar_get(nc,"latitude")
  lon = ncvar_get(nc,"longitude")
  varZ200[,,it]=var[,,1]
  print(var[50,50,1])
  it=it+1
  nc_close(nc)
}

varZ200mean <- array(NA, dim=c(360,181))
varZ200mean <- rowMeans( varZ200[,,1:4] ,dims=2 )
print(varZ200mean[50,50])
dimLon <- ncdim_def('lon', units='degrees_east', longname='lon', vals=lon)
dimLat <- ncdim_def('lat', units='degrees_north', longname='lat', vals=lat)
dimTime <- ncdim_def('time', units=paste('days since 1970-',month,'-',day,' 00:00.00',sep=''), longname='time', calendar="standard", vals=c(0))

#definicion de las variables
var <- ncvar_def(name='z200', units='m', dim=list(dimLon,dimLat,dimTime),compression=1, missval=-9999, longname=paste('z200',month,day," daily analysis",sep=""))

nc_o <- nc_create(paste('z200.',fecha,".daily.AN.nc",sep=""),var)

ncvar_put(nc_o, var,varZ200mean)

nc_close(nc_o)

#Calculo de analisis medio de los ultimos 7 dias





