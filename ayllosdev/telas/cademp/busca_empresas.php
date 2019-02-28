
<?php
/*!
 * FONTE        : busca_empresas.php
 * CRIAÇÃO      : Michel Candido Gati Tecnologia
 * DATA CRIAÇÃO : 21/08/2013 
 * OBJETIVO     : Rotina para busca das empresas
 * ALTERAÇÕES   : 05/08/2014 - Inclusão da opção de Pesquisa (Vanessa)
 *				  28/07/2016 - Corrigi o uso das variaveis do post e do XML. SD 491925 (Carlos R.)
 *      		  14/09/2018 - Tratamento para o projeto 437 Consignado (incluir  flnecont e tpmodcon)
 *      		  14/09/2018 - Tratamento para o projeto 437 Consignado (substituir o PROGRESS que recupera a lista de empresas por uma PROCEDURE ORACLE)
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
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	if ( $cdempres >= 0 ) {
		$xml .= '       <nmextemp></nmextemp>';
		$xml .= '       <nmresemp></nmresemp>';
	}
	else if ($cdpesqui == 0)
	{
		$xml .= '       <nmextemp>'.strtoupper($nmdbusca).'</nmextemp>';
		$xml .= '       <nmresemp></nmresemp>';
	}
	else
	{
		$xml .= '       <nmextemp></nmextemp>';
		$xml .= '       <nmresemp>'.strtoupper($nmdbusca).'</nmresemp>';
	}
	$xml .= '       <nrdocnpj></nrdocnpj>';
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';
	$xml .= '       <cddopcao>'.$cdpesqui.'</cddopcao>';
	$xml .= '       <nriniseq>1</nriniseq>';
	$xml .= '       <nrregist>30</nrregist>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';


	$xmlResult = mensageria(
		$xml,
		"TELA_CADEMP",
		"OBTEM_DADOS_EMPRESA",
		$glbvars["cdcooper"],
		$glbvars["cdagenci"],
		$glbvars["nrdcaixa"],
		$glbvars["idorigem"],
		$glbvars["cdoperad"],
		"</Root>");

	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO" ) {
		exibirErro(
			"error",
			$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,
			"Alerta - Ayllos",
			"focaCampoErro(\'cdempres\', \'frmInfEmpresa\');",
			false);
		
		exit();
	} //erro
	
	$registros = ( isset($xmlObj->roottag->tags[0]->tags) ) ? $xmlObj->roottag->tags[0]->tags : array();
	include('tab_empresas.php');
?>