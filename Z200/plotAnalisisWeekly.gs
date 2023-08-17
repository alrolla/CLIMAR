function main(args)

*==========================================================================
* Plot weekly anomaly
* pass fecha(date) as a parameter
*==========================================================================

'reset'
'reinit'
'set grid on'
'set grads off'
'set mpdset hires'
'set parea 0 11 0 6.5469'

'set mproj off'
'set frame off'
'set grid off'
'set mpdraw off'
'set xlab off'
'set ylab off'
'set grads off'

fecha=subwrd(args,1);

'sdfopen z200.'fecha'.anom.AN.nc'
say 'sdfopen z200.'fecha'.anom.AN.nc'
'set rgb 50 163 3 14'
'set rgb 51 196 4 17'
'set rgb 52 227 14 24'
'set rgb 53 250 51 32'
'set rgb 54 250 89 40'
'set rgb 55 250 161 60'
'set rgb 56 250 193 87'
'set rgb 57 252 231 136'
'set rgb 58 252 249 182'
'set rgb 59 227 252 251'
'set rgb 60 183 242 247'
'set rgb 61 152 212 245'
'set rgb 62 120 186 240'
'set rgb 63 77 166 235'
'set rgb 64 62 152 237'
'set rgb 65 45 133 227'
'set rgb 66 36 114 224'
'set rgb 67 27 103 204'



'set gxout shaded'
'set csmooth on'
'set lat -80 40'

'set clevs -240 -210 -180 -150 -120 -90 -60 -30  0  30 60 90 120 150 180 210 240'
'set ccols 67   66   66    65   64   63  62  61  59 58 57 56  55  54  53  52  51 50'
'd z200'

'printim mapas/anom.z200.'fecha'.analisis.jpg x2000 y800'

quit
return
