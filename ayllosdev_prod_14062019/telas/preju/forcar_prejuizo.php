<? 
/*!
 * FONTE        : forcar_prejuizo.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Rotina para estornar o prejuizo selecionado
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
		
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$okConfirm = (isset($_POST['okConfirm'])) ? $_POST['okConfirm'] : 0;
	
	// se não confirmou o estorno, então abre tela para confirmar.
	if ($okConfirm != 1){
		echo 'hideMsgAguardo();';
		echo "showConfirmacao('Confirma a transferência a prejuízo de empréstimo?','Confirma&ccedil;&atilde;o - Ayllos','carregaPrejuizoEpr(\'$nrdconta\', \'$nrctremp\', 1);','estadoInicial();','sim.gif','nao.gif');";
		exit();
	}else{
		// se confirmar
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "PREJU", "TRANSF_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		$xmlObj = simplexml_load_string($xmlResult);
	
		$error = $xmlObj->Erro->Registro->erro;
		if ($error == "yes"){
			$msgErro = utf8_decode($xmlObj->Erro->Registro->dscritic);
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}else{
			echo 'hideMsgAguardo();';
			echo 'showError("inform","Transferência a prejuízo de empréstimo, efetuada com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}
	}
?>