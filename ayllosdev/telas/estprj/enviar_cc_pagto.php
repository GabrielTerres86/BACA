<? 
/*!
 * FONTE        : estornar_pagto.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : Rotina para estornar o pagamento do prejuizo 
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
		
    $nrdconta1 = (isset($_POST['nrdconta1'])) ? $_POST['nrdconta1'] : 0;
	$nrctremp1 = (isset($_POST['nrctremp1'])) ? $_POST['nrctremp1'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta1."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp1."</nrctremp>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
    
	$xmlResult = mensageria($xml, "ESTPRJ", "DESFAZ_PAGTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	exibirErro("inform","Operacao efetuada com sucesso...","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
	exit();
}	
	
?>