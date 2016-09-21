<? 
/*!
 * FONTE        : busca_empresas.php
 * CRIAÇÃO      : Michel Candido Gati Tecnologia
 * DATA CRIAÇÃO : 21/08/2013 
 * OBJETIVO     : Rotina para busca das empresas
 * ALTERAÇÕES   : 05/08/2014 - Inclusão da opção de Pesquisa (Vanessa)
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
	$nmdbusca = $_POST['nmdbusca']; 
	$cdpesqui = $_POST['cdpesqui'];
	$cdcooper = $_POST['cdcooper'];
	$cdempres = !empty($_POST['cdempres']) ? $_POST['cdempres'] : -1;
	//	echo $cdempres;
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0166.p</Bo>";
	$xml .= "        <Proc>Busca_empresas</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xml .= "        <nmdbusca>".strtoupper($nmdbusca)."</nmdbusca>";
	$xml .= "        <cdpesqui>".$cdpesqui."</cdpesqui>";
	$xml .= "        <cdempres>".$cdempres."</cdempres>";
	$xml .= "  </Dados>"; 
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);


	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);


	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','btnVoltar();',false);
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
	
	include('tab_empresas.php');
?>