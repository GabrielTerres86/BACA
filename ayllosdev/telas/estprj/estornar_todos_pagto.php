<? 
/*!
 * FONTE        : estornar_todos_pagto.php
 * CRIAÇÃO      : Rafael Muniz Monteiro (Mout´S)
 * DATA CRIAÇÃO : 02/04/2018
 * OBJETIVO     : Rotina para estornar todos os pagamentos listados
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	$dtprejuz = (isset($_POST['dtpagto'])) ? $_POST['dtpagto'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dtprejuz>".$dtpagto."</dtprejuz>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
    
	$xmlResult = mensageria($xml, "ESTPRJ", "CONSULTA_ESTPRJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	
	$aRegistros = $xmlObj->roottag->tags;	
	
	foreach ($aRegistros as $oEstorno) {
		$nrdconta1 = getByTagName($oEstorno->tags,'nrdconta');
		$nrctremp1 = getByTagName($oEstorno->tags,'nrctremp');		
        echo "<script>carregaTelaEstornar($nrdconta1, $nrctremp1);</script>";     	
	}	
	
?>