<?
/* 
 * FONTE        : download.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : Agosto/2016
 * OBJETIVO     : Download de imagens de cheques
 * --------------
 * ALTERAÇÕES   : 
 * --------------
*/

session_start();

// Obtem SIDLOGIN da sessão para verificar se o usuário está logado
// O parâmetro deve ser passado criptografado para evitar acesso direto pelo Browser
$sidlogin = base64_decode($_GET['sidlogin']);

// Criar a variável POST para alimentar a variável global $glbvars na include config.php
$_POST["sidlogin"] = $sidlogin;	
	
// Includes para variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Verifica se o usuário está logado no sistema
if (!isset($glbvars['cdcooper'])) {
	echo "É preciso estar logado ao sistema para visualizar a imagem.";
	exit();
}

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@",false)) <> "") {				
	echo $msgError;
	exit();
}

$tif = strip_tags($_GET['src']);
$apagartb = strip_tags($_GET['apagartb']);

if (!file_exists($tif)) {
	echo "Imagem não encontrada.";
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