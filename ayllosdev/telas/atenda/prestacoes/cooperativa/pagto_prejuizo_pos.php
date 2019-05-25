<? 
/*!
 * FONTE        : pagto_prejuizo_pos.php
 * CRIAÇÃO      : Nagasava (Supero)
 * DATA CRIAÇÃO : 21/01/2019
 * OBJETIVO     : Rotina para pagar o prejuizo do contrato pos
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> ''){
		exibirErro('error',$msgError,'Alerta - Aimaro','',true);
	}
		
    $nrdconta = ( (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0);
	$nrctremp = ( (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0);
	$vlpagmto = ( (isset($_POST['vlpagmto']) && is_numeric($_POST['vlpagmto'])) ? $_POST['vlpagmto'] : 0);
	$vldabono = ( (isset($_POST['vldabono']) && is_numeric($_POST['vldabono'])) ? $_POST['vldabono'] : 0);
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= "   <vlpagmto>".$vlpagmto."</vlpagmto>";	
	$xml .= "   <vldabono>".$vldabono."</vldabono>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";	
	
	$xmlResult = mensageria($xml, "ATENDA", "EFETUA_PAGTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro,"E");
	
	}else{
		exibeErroNew("Pagamento efetuado com sucesso.","I");
	}
	
	
	function exibeErroNew($msgErro,$tipo) {	
		if($tipo == "E"){
		  echo 'hideMsgAguardo();';
		  echo 'showError("error","'.$msgErro.'","Alerta - Aimaro", "bloqueiaFundo(divRotina);");';
		  exit();
		}else{
		  echo 'hideMsgAguardo();';
		  echo 'showError("inform","'.$msgErro.'","Alerta - Aimaro", "controlaOperacao(\'C_PAG_PREST_POS_PRJ\');");';
		  exit();
		}
	}
	
?>