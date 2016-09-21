<?
/*!
 * FONTE        : processa_dados.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : 01/02/2016
 * OBJETIVO     : Tabela de Alteracao/Inclusao/Exclusao para a tela TRNBCB
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = $_POST["cddopcao"];
	$cddtrans = $_POST["cddtrans"];		
	$dstrnbcb = $_POST["dsctrans"];
	$flgdebcc = $_POST["flgdebcc"];
	$tphistor = $_POST["tphistor"];
	
	$cdhistor = !isset($_POST["cdhistor"]) || is_null($_POST["cdhistor"]) || $_POST["cdhistor"] == '' ? 0 : $_POST["cdhistor"];	
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdtrnbcb>".$cddtrans."</cdtrnbcb>";
	$xml .= "   <dstrnbcb>".$dstrnbcb."</dstrnbcb>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <flgdebcc>".$flgdebcc."</flgdebcc>";
	$xml .= "   <tphistor>".$tphistor."</tphistor>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TRNBCB", "TRNBCB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	
//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
}

if($cddopcao == 'A1'){
	exibirErro('inform','Alterado com sucesso.','Alerta - Ayllos','',false);
}elseif($cddopcao == 'I1'){
	exibirErro('inform','Inclu&iacute;do com sucesso.','Alerta - Ayllos','',false);
}elseif($cddopcao == 'E1') {
	exibirErro('inform','Exclu&iacute;do com Sucesso.','Alerta - Ayllos','',false);
}
	
	

?>