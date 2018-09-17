<? 
/*!
 * FONTE        : realiza_exclusao.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 27/06/2011
 * OBJETIVO     : Executa os processos da rotina filha de Simula��es da rotina de Empr�stimos 
**/
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	
	isPostMethod();
	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrsimula = (isset($_POST['nrsimula'])) ? $_POST['nrsimula'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisi��o
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Cabecalho>";
	$xml.= "		<Bo>b1wgen0097.p</Bo>";
	$xml.= "		<Proc>exclui_simulacao</Proc>";
	$xml.= "	</Cabecalho>";
	$xml.= "	<Dados>";
	$xml.= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml.= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml.= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml.= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml.= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml.= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
    $xml.= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgerlog>TRUE</flgerlog>";
	$xml.= "		<nrsimula>".$nrsimula."</nrsimula>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ){
		echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	}
	else{
		echo "mostraTabelaSimulacao('TS');";
	}
?>