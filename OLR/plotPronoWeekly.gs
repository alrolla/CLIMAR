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
varn=subwrd(args,2);
iw=subwrd(args,3);

'sdfopen anom.'varn'.'fecha'.week'iw'.nc'

# 'set rgb 50 163 3 14'
# 'set rgb 51 196 4 17'
# 'set rgb 52 227 14 24'
# 'set rgb 53 250 51 32'
# 'set rgb 54 250 89 40'
# 'set rgb 55 250 161 60'
# 'set rgb 56 250 193 87'
# 'set rgb 57 252 231 136'
# 'set rgb 58 252 249 182'
# 'set rgb 59 227 252 251'
# 'set rgb 60 183 242 247'
# 'set rgb 61 152 212 245'
# 'set rgb 62 120 186 240'
# 'set rgb 63 77 166 235'
# 'set rgb 64 62 152 237'
# 'set rgb 65 45 133 227'
# 'set rgb 66 36 114 224'
# 'set rgb 67 27 103 204'

'set rgb 50 72  3 74'
'set rgb 51 146 3 50'
'set rgb 52 192 4 199'
'set rgb 53 125 4 224'
'set rgb 54 63  4 224'
'set rgb 55 44 98 199'
'set rgb 56 69 201 237'
'set rgb 57 255 255 255'
'set rgb 58 255 255 255'
'set rgb 59 111 227 9'
'set rgb 60 200 227 23'
'set rgb 61 250 228 30'
'set rgb 62 250 228 40'
'set rgb 63 247 168 32'
'set rgb 64 245 98 29'
'set rgb 65 245 5 29'




*'set map 0 1 3'
*'set mpdset mres'

'set gxout shaded'
'set csmooth on'
'set lat -80 40'

'set clevs    -100 -80 -70 -60 -40 -30 -10 10 30 40 60 70 80 100'
'set ccols 50   51  52  53  54  55  56  57 59 60 61 62 63 64 65'
'd 'varn
*'set gxout contour '
*'set clab off'
*'set clevs -20 -16 -12 -8 -4 -2 -1 1  2  4  8  12 16 20'
*'d 'varn
'printim mapas/anom.'varn'.'fecha'.week'iw'.jpg x2000 y800'


*'cbarn'



*'draw title Anomalia Precip (mm/dia) 28Mar2015-3Apr2015'
*'printim Figura4a.png x800 y1000 white'
quit
return
