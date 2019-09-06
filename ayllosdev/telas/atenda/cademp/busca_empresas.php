
<?php
/*!
 * FONTE        : busca_empresas.php
 * CRIAÇÃO      : Michel Candido Gati Tecnologia
 * DATA CRIAÇÃO : 21/08/2013 
 * OBJETIVO     : Rotina para busca das empresas
 * ALTERAÇÕES   : 05/08/2014 - Inclusão da opção de Pesquisa (Vanessa)
 *				  28/07/2016 - Corrigi o uso das variaveis do post e do XML. SD 491925 (Carlos R.)
 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Guardo os parâmetos do POST em variáveis	
	$nmdbusca = ( isset($_POST['nmdbusca']) ) ? $_POST['nmdbusca'] : ''; 
	$cdpesqui = ( isset($_POST['cdpesqui']) ) ? $_POST['cdpesqui'] : '';
	$cdempres = ( isset($_POST['cdempres']) && !empty($_POST['cdempres']) ) ? $_POST['cdempres'] : -1;
	
	//remove & (e comercial) da descricao da empresa filtrada
	$pattern = '/(&){1,}/';
	$replacement = '';
	$nmdbusca = preg_replace($pattern, $replacement, $nmdbusca);		
	
	$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0166.p</Bo>";
	$xml .= "        <Proc>Busca_empresas</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
	$xml .= "        <nmdbusca>".strtoupper($nmdbusca)."</nmdbusca>";
	$xml .= "        <cdpesqui>".$cdpesqui."</cdpesqui>";
	$xml .= "        <cdempres>".$cdempres."</cdempres>";
	$xml .= "  </Dados>"; 
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','focaCampoErro(\'cdempres\', \'frmInfEmpresa\');',false);
	}

	$registros = ( isset($xmlObj->roottag->tags[0]->tags) ) ? $xmlObj->roottag->tags[0]->tags : array();
	include('tab_empresas.php');
?>