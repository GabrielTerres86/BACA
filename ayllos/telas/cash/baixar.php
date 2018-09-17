<?php
/*
 * FONTE        : baixar.php
 * CRIAÇÃO      : Carlos Henrique
 * DATA CRIAÇÃO : 13/09/2016 
 * OBJETIVO     : Baixar o arquivo csv gerado na tela CASH, opção C, Transação, Depósitos, botão Exportar; e excluir os arquivos gerados
 *                ha mais de uma hora.
 * --------------
 * ALTERAÇÕES   :  
 * --------------
 */

$coop = $_GET['coop'];
$dir = '../../documentos/'.$coop.'/temp/';
$arq = $_GET['arquivo'];
$nmarquivo = $dir . $arq;

$fp = @fopen($nmarquivo, 'rb');	

if (strstr($_SERVER['HTTP_USER_AGENT'], "MSIE")) {
	header('Content-Type: "application/octet-stream"');
	header('Content-Disposition: attachment; filename="'.$arq."'");
	header('Expires: 0');
	header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
	header("Content-Transfer-Encoding: binary");
	header('Pragma: public');
	header("Content-Length: ".filesize($nmarquivo));
} else {
	header('Content-Type: "application/octet-stream"');
	header('Content-Disposition: attachment; filename="'.$arq.'"');
	header("Content-Transfer-Encoding: binary");
	header('Expires: 0');
	header('Pragma: no-cache');
	header("Content-Length: ".filesize($nmarquivo));
}

fpassthru($fp);
fclose($fp); 

/*** Exclui os arquivos temporarios criados ha mais de uma hora ***/
foreach (glob($dir."cash_depositos*.csv") as $file) {	
	if (filemtime($file) < time() - 3600) { // 3600 = uma hora
		unlink($file);
    }
}
?>