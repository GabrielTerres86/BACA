<?php
/*************************************************************************
Fonte: gnuclient_upload_file.php
Autor: Jorge Hamaguchi
Data : Dezembro/2011                   Última Alteração:

Objetivo  : importa arquivo para o servidor.

Alterações: 17/07/2016 - Alteracao para chamada da funcao cecredCript. SD 484516

***********************************************************************/
//$Arq deve ser passado com o caminho do arquivo    * caminho/arquivo
//$dirArqDne deve ser passado o caminho				* arquivo
//$filename deve ser passado o nome do arquivo		* caminho

if (!function_exists('formataCdcooper')) {
	function formataCdcooper($cdcooper){
		while(strlen($cdcooper) < 3){
			$cdcooper = "0".$cdcooper;
		};
		return $cdcooper;
	}
}

$wArq=fopen($Arq,"r+");
$conteudo=fread($wArq,filesize($Arq));
$conteudo = formataCdcooper($glbvars["cdcooper"]).".0.".$filename.";".$conteudo;
fclose($Arq);

$key="50983417512346753284723840854609576043576094576059437609";
$texto="--msg=\"$conteudo\"";
$iv="12345678";

$NomeArq = formataCdcooper($glbvars["cdcooper"]).".0.".$filename;
$NomeArq = preg_replace("/\s/","",$NomeArq);
//$encriptado = mcrypt_cbc(MCRYPT_BLOWFISH, $key, $texto, MCRYPT_ENCRYPT, $iv);
$encriptado = cecredCript($texto);
$encriptado = preg_replace("/\n/","\\{n}",$encriptado);


$caminho = $dirArqDne;
$fp=fopen ($caminho.$NomeArq, "w+");
fwrite($fp,$encriptado);
fclose($fp);

$retorno = shell_exec('/bin/cat '.$caminho.$NomeArq.' | /usr/local/bin/gnuclient.pl --servidor="'.$DataServer.'" --porta="2503"');

$retorno = preg_replace("/\\\{n}/","\n",$retorno);

//$decriptado = mcrypt_cbc(MCRYPT_BLOWFISH, $key, $retorno, MCRYPT_DECRYPT, $iv);
$decriptado = cecredDecript($retorno);

?>
