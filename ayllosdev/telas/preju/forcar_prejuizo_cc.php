<? 
/*!
 * FONTE        : forcar_prejuizo_cc.php
 * CRIA��O      : Jean Calao (Mout�S)
 * DATA CRIA��O : 05/07/2017
 * OBJETIVO     : Rotina para for�ar transferencia de conta corrente para prejuizo
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'F')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
		
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
    
	$xmlResult = mensageria($xml, "PREJU", "TRANSF_PREJU_CC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	//exibirErro("inform","Operacao efetuada com sucesso...","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");
	exibeErroNew("Operacao efetuada com sucesso...");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
	exit();
}	
	
?>