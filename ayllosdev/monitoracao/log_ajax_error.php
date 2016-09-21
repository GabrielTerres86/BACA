<?php

	/*** Desabilitado por David ***
	$url    = $_GET["url"];
	$status = $_GET["status"];
	$statustext = $_GET["statustext"];
	
	$fp = fopen("log_ajax_error.txt","a+");
	fwrite($fp,date("[ d-m-Y H:i ]")." ".$_SERVER["REMOTE_ADDR"]." URL: ".$url." Status: ".$status." - ".$statustext."\r\n");
	fclose($fp);
	*** Desabilitado por David ***/
	
?>
<html>
<head>
<script type="text/javascript">
function fechar() {	
	window.close();
}
</script>
</head>
<body onLoad="fechar();">
</body>
</html>