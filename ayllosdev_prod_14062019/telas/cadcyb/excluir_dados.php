<? 
/*!
 * FONTE        : excluir_dados.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Rotina para excluir as informações da tabela crapcyc
 * --------------
 * ALTERAÇÕES   : 17/09/2015 - Ajustado os parametros enviados para a procedure de exclusão (Douglas - Melhoria 12)
 *				  21/06/2018 - Inserção de bordero e titulo [Vitor Shimada Assanuma (GFT)]
 * -------------- 
 */
 
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ; 
	$cdorigem = (isset($_POST['cdorigem'])) ? $_POST['cdorigem'] : 0 ; 
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0 ; 
	$nrtitulo = (isset($_POST['nrtitulo'])) ? $_POST['nrtitulo'] : 0 ; 
	
	// Monta o xml dinâmico de acordo com a operação 
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
    $xml .= "       <nrborder>".$nrborder."</nrborder>";
    $xml .= "       <nrtitulo>".$nrtitulo."</nrtitulo>";
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
