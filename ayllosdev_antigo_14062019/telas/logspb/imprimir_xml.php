<?php
/*
Autor: Bruno Luiz katzjarowski - Mout's
Data: 12/11/2018;
Ultima alteração:

Alterações:
	1 - XML retornando incompleto ou com erros - Bruno Luiz Katzjarowski - Mout's - 28/11/2018
*/
if(isset($_POST['xml'])){

	$strHeader = 'text/xml';
	libxml_use_internal_errors(true);
	$sxe = simplexml_load_string($_POST['xml']);
	if ($sxe === false) {
		echo htmlspecialchars($_POST['xml']);
		exit();
	}else{
		header('Content-Description: File Transfer');
		header('Content-Transfer-Encoding: binary');
		header('Cache-Control: must-revalidate');
		header('Expires: 0');
		header('Pragma: public');
	}

	header('Content-Type: '.$strHeader);

	echo $_POST['xml'];
}else{
	?>
	<script>
		window.close();
	</script>
	<?php
}
?>