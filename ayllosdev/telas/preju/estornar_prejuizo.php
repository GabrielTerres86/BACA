<? 
/*!
 * FONTE        : estornar_prejuizo.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Rotina para estornar o prejuizo selecionado
 * --------------
 * ALTERAÇÕES   : 03/01/2017: Confirmação de estorno. Andrey Formigari - Mouts
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
	$idtpoest1  = (isset($_POST['idtpoest1'])) ? $_POST['idtpoest1'] : 0; // RMM M324
	$okConfirm = (isset($_POST['okConfirm'])) ? $_POST['okConfirm'] : 0;
	
	// se não confirmou o estorno, então abre tela para confirmar.
	if ($okConfirm != 1){
		echo 'hideMsgAguardo();';
		echo "showConfirmacao('Confirma estorno da transferência a prejuízo?','Confirma&ccedil;&atilde;o - Ayllos','carregaTelaEstornar(\'$nrdconta1\', \'$nrctremp1\', \'$idtpoest1\', 1);','estadoInicial();','sim.gif','nao.gif');";
		exit();
	}else{
		// se confirmar
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrdconta>".$nrdconta1."</nrdconta>";
		$xml .= "   <nrctremp>".$nrctremp1."</nrctremp>";	
		$xml .= "   <idtpoest>".$idtpoest1."</idtpoest>"; // RMM M324
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "PREJU", "DESFAZ_PREJUIZO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
			echo 'showError("inform","Estorno da transferência a prejuízo efetuado com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}
	}
?>