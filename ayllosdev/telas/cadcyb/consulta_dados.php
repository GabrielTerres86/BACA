<? 
/*!
 * FONTE        : altera_cadcyb.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Rotina para alterar as informações da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 04/06/2018 - Projeto 403 - Inclusão de tratativas para a inclusão de títulos vencidos na Cyber (Lucas - GFT) 
 * -------------- 
 */
 
    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0 ; 
	$nrctremp = (isset($_POST["nrctremp"])) ? $_POST["nrctremp"] : 0 ; 
	$cdorigem = $_POST["cdorigem"];
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0 ; 
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0 ; 
	$cdassess = (isset($_POST["cdassess"])) ? $_POST["cdassess"] : 0 ; 
	$cdmotcin = (isset($_POST["cdmotcin"])) ? $_POST["cdmotcin"] : 0 ; 
	$nrborder = (isset($_POST["nrborder"])) ? $_POST["nrborder"] : 0 ; 
	$nrtitulo = (isset($_POST["nrtitulo"])) ? $_POST["nrtitulo"] : 0 ; 

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0170.p</Bo>";
	$xml .= "		<Proc>consulta-dados-crapcyc</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
    $xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "       <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "       <cdorigem>".$cdorigem."</cdorigem>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<cdassess>".$cdassess."</cdassess>";
	$xml .= "		<cdmotcin>".$cdmotcin."</cdmotcin>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";
	$xml .= "		<nrtitulo>".$nrtitulo."</nrtitulo>";
	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
	} 
			
	$registros = $xmlObjeto->roottag->tags[0]->tags;		   
	$qtregist  = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	
	include("form_consulta.php");	
?>