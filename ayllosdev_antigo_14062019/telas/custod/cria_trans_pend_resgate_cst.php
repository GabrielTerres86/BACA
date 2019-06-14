<?php
/*!
 * FONTE        : cria_trans_pend_resgate_cst.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 19/01/2018
 * OBJETIVO     : Rotina para criar transacao pendente 
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */		

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();			

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrcpfrep = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0;
$dscheque = (isset($_POST['dscheque'])) ? $_POST['dscheque'] : 0;

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <idseqttl>1</idseqttl>";
$xml .= "   <nrcpfrep>".$nrcpfrep."</nrcpfrep>";
$xml .= "   <nrcpfope>0</nrcpfope>";
$xml .= "   <cdcoptfn>0</cdcoptfn>";
$xml .= "   <cdagetfn>0</cdagetfn>";
$xml .= "   <cdagetfn>0</cdagetfn>";
$xml .= "   <idastcjt>1</idastcjt>";
$xml .= "   <dscheque>".$dscheque."</dscheque>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "CRIA_TRANS_PEND_RESGATE_CST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	exit();
}else{
	echo 'limpaGridCheques();';
	echo 'estadoInicial();';
	$msgErro = 'Pendencias de aprovacao criadas com sucesso';
	exibirErro('inform',$msgErro,'Alerta - Aimaro','',false);
}

?>
