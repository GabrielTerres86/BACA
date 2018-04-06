<?php
/* 
  FONTE        : busca_cartoes.php
  CRIAÇÃO      : Kelvin Souza Ott
  DATA CRIAÇÃO : 23/06/2017
  OBJETIVO     : Rotina para controlar as operações da tela MANCRD
  --------------
  ALTERAÇÕES   : 27/10/2017 - Efetuar ajustes e melhorias na tela (Lucas Ranghetti #742880) 
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

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_MANCRD", "PC_BUSCA_CARTOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibirErro('error', $msgErro, 'Alerta - Ayllos', "", true);    
}

$registros = $xmlObj->roottag->tags;

$nmprimtl  = $registros[0]->tags[13]->cdata;

include('tab_cartoes.php');

?>
<script type="text/javascript">
	
	cNmprimtl.val("<? echo $nmprimtl; ?>");
    	
</script>