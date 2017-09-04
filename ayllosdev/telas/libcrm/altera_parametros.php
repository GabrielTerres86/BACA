<?php
/* 
  FONTE        : altera_parametros.php
  CRIAÇÃO      : Kelvin Souza Ott
  DATA CRIAÇÃO : 09/08/2017
  OBJETIVO     : Rotina para controlar as operações da tela LIBCRM
  --------------
  ALTERAÇÕES   : 
  -------------- 
 */
?> 

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$flgaccrm = (isset($_POST['flgaccrm'])) ? $_POST['flgaccrm'] : 0;

if($flgaccrm == ""){
	exibirErro('error', 'Libera acesso ao sistema Ayllos e de preenchimento obrigatorio!', 'Alerta - Ayllos', "", false);   
	return;
}
	
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <flgaccrm>" . $flgaccrm . "</flgaccrm>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_LIBCRM", "PC_ALTERA_PARAMETROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);    
} 
else{
	exibirErro('inform', 'Parametros atualizado com sucesso.', 'Alerta - Ayllos', "fechaRotina($('#divRotina'));", false);
}

?>