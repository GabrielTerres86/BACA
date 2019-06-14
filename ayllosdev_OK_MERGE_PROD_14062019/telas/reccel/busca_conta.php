<?
/*!
 * FONTE        : busca_conta.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/03/2017
 * OBJETIVO     : Realiza a pesquisa do titular pela conta informada
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
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$form = (isset($_POST['nomeForm'])) ? $_POST['nomeForm'] : '';

	if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "TELA_RECCEL", "BUSCA_INF_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
	} 
		
	$nmprimtl	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmprimtl');
	
	echo "$('#nmprimtl', '#$form').val('$nmprimtl');";
	echo "liberaCampos();"
	
?>