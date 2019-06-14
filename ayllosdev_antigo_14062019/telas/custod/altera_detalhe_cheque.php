<?php
/*!
 * FONTE        : altera_detalhe_cheque.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 28/09/2016
 * OBJETIVO     : Rotina para alterar os dados do cheque custodiado da remessa
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
$nrconven = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;
$nrremret = (isset($_POST['nrremret'])) ? $_POST['nrremret'] : 0;
$intipmvt = (isset($_POST['intipmvt'])) ? $_POST['intipmvt'] : 0;
$dsdocmc7 = (isset($_POST['dsdocmc7'])) ? $_POST['dsdocmc7'] : '';
$dtemissa = (isset($_POST['dtemissa'])) ? $_POST['dtemissa'] : '';
$dtlibera = (isset($_POST['dtlibera'])) ? $_POST['dtlibera'] : '';
$vlcheque = (isset($_POST['vlcheque'])) ? $_POST['vlcheque'] : 0;
$inconcil = (isset($_POST['inconcil'])) ? $_POST['inconcil'] : 0;
	
// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrremret>".$nrremret."</nrremret>";
$xml .= "   <intipmvt>".$intipmvt."</intipmvt>";
$xml .= "   <dsdocmc7>".$dsdocmc7."</dsdocmc7>";
$xml .= "   <dtemissa>".$dtemissa."</dtemissa>";
$xml .= "   <dtlibera>".$dtlibera."</dtlibera>";
$xml .= "   <vlcheque>".$vlcheque."</vlcheque>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_CUSTOD", "CUSTOD_ALTERA_DETALHE_CHEQUE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\')); $(\'#dtemissa\', \'#frmDetalheCheque\').focus();',false);
	exit();
}else{
	echo 'fechaRotina($(\'#divRotina\'));';
	echo 'buscaChequesRemessa();';
	echo 'hideMsgAguardo();';
	if ($inconcil == 1){
		$msgErro = 'Dados do cheque alterados com sucesso! Cheque foi desconciliado.';
	}else{
		$msgErro = 'Dados do cheque alterados com sucesso!';
	}
	exibirErro('inform',$msgErro,'Alerta - Aimaro','',false);
}

?>
