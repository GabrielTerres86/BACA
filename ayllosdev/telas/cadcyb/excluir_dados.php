<? 
/*!
 * FONTE        : excluir_dados.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Agosto/2013
 * OBJETIVO     : Rotina para excluir as informa��es da tabela crapcyc
 * --------------
 * ALTERA��ES   : 17/09/2015 - Ajustado os parametros enviados para a procedure de exclus�o (Douglas - Melhoria 12)
 * -------------- 
 */
 
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a opera��o que est� sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ; 
	$cdorigem = (isset($_POST['cdorigem'])) ? $_POST['cdorigem'] : 0 ; 
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0170.p</Bo>";
	$xml .= "		<Proc>excluir-dados-crapcyc</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "       <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "       <cdorigem>".$cdorigem."</cdorigem>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} 
	
	echo 'showError("inform","Lan&ccedil;amento exclu&iacute;do com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
			
?>
