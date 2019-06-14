<? 
/*******************************************************************************************
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Michel Candido - Gati
 * DATA CRIAÇÃO : 11/11/2013
 * OBJETIVO     : Tela da tabela de contrato
 *-----------
 *Alterações: 11/03/2014 - Ajustes para deixar fonte no padrão, Softdesk - 130006 (Lucas R).
 *-----------
 *
 ********************************************************************************************/ 
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
	$busca    = (isset($_POST["busca"]) ? $_POST["busca"] : '');

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0165.p</Bo>";
	$xml .= "        <Proc>Busca_Contrato</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <idseqttl>".$glbvars["idseqttl"]."</idseqttl>";
	$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "        <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xml .= "        <inproces>".$glbvars["inproces"]."</inproces>";
	$xml .= "        <flgerlog>".$glbvars["flgerlog"]."</flgerlog>";
	$xml .= "        <flgcondc>".$glbvars["flgcondc"]."</flgcondc>";
	$xml .= "        <flgempt0>YES</flgempt0>"; /* listar apenas tpemprst 0 */
	$xml .= "        <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}

	$registros = $xmlObj->roottag->tags[1]->tags;

	include('tab_contrato.php');

?>