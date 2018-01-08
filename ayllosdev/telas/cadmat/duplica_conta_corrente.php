<?
/*!
 * FONTE        : duplica_conta_corrente.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/10/2017
 * OBJETIVO     : Duplica nova conta corrente do cooperado a partir de uma conta antiga
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta_org = (isset($_POST['nrdconta_org'])) ? $_POST['nrdconta_org'] : '';
	$nrdconta_dst = (isset($_POST['nrdconta_dst'])) ? $_POST['nrdconta_dst'] : '';

	if (!validaInteiro($nrdconta_dst) || $nrdconta_dst == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
    $xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "		<nrdconta_org>".$nrdconta_org."</nrdconta_org>";
    $xml .= "		<nrdconta_dst>".$nrdconta_dst."</nrdconta_dst>";
    $xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "MATRIC", "DUPLICACAO_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);
	} 
	setVarSession("CRM_NRDCONTA",$nrdconta_dst);
	exibirErro('inform','A conta utilizada foi ' . formataContaDVsimples($nrdconta_dst) . '.','Alerta - Ayllos','verificaRelatorio();',false);
	
?>