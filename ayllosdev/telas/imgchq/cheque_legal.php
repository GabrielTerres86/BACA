<?php

	include("../../includes/config.php");
	
	if ((isset($_GET["cmc7"]) && isset($_GET["cpfcnpj"])) || (isset($_POST["cmc7"]) && isset($_POST["cpfcnpj"]))) {  		
		
		$cmc7    = isset($_POST["cmc7"])    ? urlencode(strip_tags($_POST["cmc7"]))    : urlencode(strip_tags($_GET["cmc7"]));
		$cpfcnpj = isset($_POST["cpfcnpj"]) ? urlencode(strip_tags($_POST["cpfcnpj"])) : urlencode(strip_tags($_GET["cpfcnpj"]));		
		
		$key = "50983417512346753284723840854609576043576094576059437609";
		$iv  = "12345678";
		
		$NomeArq = microtime(1).getmypid();
		$NomeArq = preg_replace("/\s/","",$NomeArq);
		
		// Comando para requisi��o de dados pelo script gnuclient
		$command = '"codigoCMC7='.$cmc7.'" "cpf_cnpj='.$cpfcnpj.'"';			
				
		$encriptado = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$command,MCRYPT_ENCRYPT,$iv);
		$encriptado = preg_replace("/\n/","\\{n}",$encriptado);
		
		$fp = fopen("/var/www/ayllos/xml/$NomeArq","w+");
		fwrite($fp,$encriptado);
		fclose($fp);
			
		// Executa o shell	
		$xmlResult = shell_exec('/bin/cat /var/www/ayllos/xml/'.$NomeArq.' | /usr/local/bin/gnuclient.pl --servidor="'.$DataServer.'" --porta="2504"');
		
		unlink("/var/www/ayllos/xml/$NomeArq");
		
		$decriptado = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$xmlResult,MCRYPT_DECRYPT,$iv);
		$decriptado = eregi_replace('/\e\040/',"",$decriptado);		
		$decriptado = strip_tags(preg_replace("/\n/","",$decriptado));		
		
		echo $decriptado;

	} else {
	
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Pragma" content="no-cache">
<title>Teste - Cheque Legal</title>
<style type="text/css">
* {
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
	font-weight: bold;
}
label {
	width: 60px;	
}
.campo {
	width: 230px;
}
</style>
</head>
<body>
	<form action="" method="post" name="frmChequeLegal" id="frmChequeLegal">
		<label for="cmc7">CMC-7:</label>
		<input type="text" name="cmc7" id="cmc7" class="campo" />
		<br />
		<label for="cpfcnpj">CPF/CNPJ:</label>
		<input type="text" name="cpfcnpj" id="cpfcnpj" class="campo" />
		<br /><br />
		<input type="submit" name="btnEnvia" id="btnEnvia" value="Enviar Requisi��o" />
	</form>
</body>
</html>
<?php 

	} 

?>