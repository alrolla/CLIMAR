<?php
$arch=$argv[1];
$var=$argv[2];

//anom.pre.20150809.week1f.png

$fecha=substr($arch,9,4)."-".substr($arch,13,2)."-".substr($arch,15,2);

echo $arch."\n";
echo $fecha."\n";
echo $var."\n";


// inserto el registro con la variable fecha en la base de datos

	$servername = "localhost";
	$username = "alrolla";
	$password = " ";
	$dbname = "CFS";

	// Create connection
	$conn = mysqli_connect($servername, $username, $password, $dbname);
	// Check connection
	if (!$conn) {
		die("Fallo de conexion: " . mysqli_connect_error());
	}

	$sql = "INSERT INTO ControlProcesoCFS (Variable, Fecha) VALUES ('".$var."', '".$fecha."')";
    
    if (mysqli_query($conn, $sql)) {
    	echo "Registro agregado";
	} else {
    	echo "Error: " . $sql . "<br>" . mysqli_error($conn);
	}					
	mysqli_close($conn);

?>
