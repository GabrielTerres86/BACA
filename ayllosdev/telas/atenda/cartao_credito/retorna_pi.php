<?
/*!
 * FONTE        : retorna_pi.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Julho/2014
 * OBJETIVO     : Retorna o PIN-BLOCK
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();
	
	if (!isset($_POST["dataWk"]) || !isset($_POST["dataPin"])){		
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	$sWorkingKey = base64_decode($_POST['dataWk']);
	$sPinBlock   = base64_decode($_POST['dataPin']);	
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <workingkey>".$sWorkingKey."</workingkey>";
	$xml .= "   <pinblock>".$sPinBlock."</pinblock>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "ENTREGAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj    = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){
		echo '{"bErro":"1","retorno":"'.$xmlObj->roottag->tags[0]->cdata.'"}';
	}else if (trim($xmlObj->roottag->tags[0]->cdata) == ""){
		echo '{"bErro":"1","retorno":"Erro ao criptografar senha."}';
	}else{
		echo '{"bErro":"0","retorno":"'.base64_encode($xmlObj->roottag->tags[0]->cdata).'"}';
	}	
?>