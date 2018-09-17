<? 
/*!
 * FONTE        : importa_arquivo.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 20/07/2017
 * OBJETIVO     : Rotina para importar arquivo com contas/contratos para forçar envio para prejuizo
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'F')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

    $nrdconta = (isset($_POST['nmdarqui'])) ? $_POST['nmdarqui'] : 0;
	$okConfirm = (isset($_POST['okConfirm'])) ? $_POST['okConfirm'] : 0;
	
	// se não confirmou o estorno, então abre tela para confirmar.
	if ($okConfirm != 1){
		echo 'hideMsgAguardo();';
		echo "showConfirmacao('Confirma a transferência a prejuízo da conta corrente?','Confirma&ccedil;&atilde;o - Ayllos','importaArquivo($(\'#nmdarqui\', \'#frmImportar\'), 1);','estadoInicial();','sim.gif','nao.gif');";
		exit();
	}else{
	
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nmdarqui>".$nrdconta."</nmdarqui>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "PREJU", "IMPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
			echo 'showError("inform","Processado com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}
	}	
?>