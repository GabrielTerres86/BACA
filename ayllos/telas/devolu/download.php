<?
/* 
 * FONTE        : download.php
 * CRIA��O      : Lucas Ranghetti
 * DATA CRIA��O : Agosto/2016
 * OBJETIVO     : Download de imagens de cheques
 * --------------
 * ALTERA��ES   : 
 * --------------
*/

session_start();

// Obtem SIDLOGIN da sess�o para verificar se o usu�rio est� logado
// O par�metro deve ser passado criptografado para evitar acesso direto pelo Browser
$sidlogin = base64_decode($_GET['sidlogin']);

// Criar a vari�vel POST para alimentar a vari�vel global $glbvars na include config.php
$_POST["sidlogin"] = $sidlogin;	
	
// Includes para vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Verifica se o usu�rio est� logado no sistema
if (!isset($glbvars['cdcooper'])) {
	echo "� preciso estar logado ao sistema para visualizar a imagem.";
	exit();
}

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@",false)) <> "") {				
	echo $msgError;
	exit();
}

$tif = strip_tags($_GET['src']);
$apagartb = strip_tags($_GET['apagartb']);

if (!file_exists($tif)) {
	echo "Imagem n�o encontrada.";
	exit();
}

$nm_file = ereg_replace('^.*/','',$tif);

// cache da imagem 24 horas
$seconds_to_cache = 86400;
$ts = gmdate('D, d M Y H:i:s', time() + $seconds_to_cache) . ' GMT';
header("Expires: $ts");
header('Pragma: cache');
header("Cache-Control: maxage=$seconds_to_cache");
header('Content-Disposition: attachment; filename="'.$nm_file.'"');
@readfile($tif);
flush();

unlink($tif);
unlink($apagartb);
?>