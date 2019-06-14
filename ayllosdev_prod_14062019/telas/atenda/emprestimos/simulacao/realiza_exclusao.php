<? 
/*!
 * FONTE        : realiza_exclusao.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simulações da rotina de Empréstimos 
 *
 * 001: [28/02/2018] Alterado para buscar os dados na mensageria Oracle (P438 Douglas Pagel / AMcom)
**/
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	
	isPostMethod();
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Monta o xml de requisição
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Dados>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml.= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml.= "		<nrsimula>".$nrsimula."</nrsimula>";
	$xml .= "		<flgerlog>1</flgerlog>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_ATENDA_SIMULACAO", "SIMULA_EXCLUI_SIMULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ){
		echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	}
	else{
		echo "mostraTabelaSimulacao('TS');";
	}
?>