setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 2 -file "/afs/athena.mit.edu/user/m/t/mtung/6.111/lab2/lab2b/rs232.bit"
Program -p 2 
Program -p 2 
Program -p 2 
setMode -bs
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
