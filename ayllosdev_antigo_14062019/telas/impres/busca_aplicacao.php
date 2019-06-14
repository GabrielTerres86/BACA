<? 
/*!
 * FONTE        : busca_aplicacao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 31/09/2011 
 * OBJETIVO     : Rotina para busca das aplicações
 *
 * ALTERAÇÕES	: 28/01/2015 - Alterado para apresentar os novos produtos de captação. (Reinert)
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$idseqttl = 1;
	$nraplica = 0;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0081.p</Bo>";
	$xml .= "        <Proc>obtem-dados-aplicacoes</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<nraplica>".$nraplica."</nraplica>";
	$xml .= '		<cdprogra>IMPRES</cdprogra>';	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	<idseqttl>".$idseqttl."</idseqttl>";	
	$xml .= "	<nraplica>".$nraplica."</nraplica>";
	$xml .= "   <cdprodut>0</cdprodut>";
	$xml .= "   <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "   <idconsul>5</idconsul>";
	$xml .= "   <idgerlog>0</idgerlog>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "EXTRDA", "EXTRDA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','',false);
	}
		
	$registros2 = $xmlObj->roottag->tags;		
	
	include('tab_aplicacao.php');
?>