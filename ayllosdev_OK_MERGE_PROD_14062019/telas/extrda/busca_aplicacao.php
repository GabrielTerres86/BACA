<? 
/*!
 * FONTE        : busca_aplicacao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 02/08/2011 
 * OBJETIVO     : Rotina para busca das aplicações
 *
 * ALTERAÇÕES	: 05/11/2014 - Adicionada estrutura de novos produtos de captacao. (Reinert)
 *
 *				  31/03/2015 - Corrigido o tratamento de erro para a nova estrutura de consulta
 *							   atraves do PL/SQL. (Jean Michel)	
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
	$idseqttl = 0;
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
	$xml .= '		<cdprogra>EXTRDA</cdprogra>';	
	$xml .= '		<flgerlog>false</flgerlog>';	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
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
		
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
		exit();
	}
		
	$registros2 = $xmlObj->roottag->tags;		

	include('tab_aplicacao.php');	
?>