<? 
/*!
 * FONTE        : forcar_prejuizo_cc.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Rotina para forçar transferencia de conta corrente para prejuizo
 * --------------
 * ALTERAÇÕES   : 03/01/2017: Confirmação de estorno. Andrey Formigari - Mouts
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	/*require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');	*/
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'F')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
		
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$okConfirm = (isset($_POST['okConfirm'])) ? $_POST['okConfirm'] : 0;
	$nmdatela = "PREJU";
	$cdfinemp = 66;
	$cdlcremp = 100;
	$idseqttl = 1;
	
	// se não confirmou o estorno, então abre tela para confirmar.
	if ($okConfirm != 1){
		echo 'hideMsgAguardo();';
		echo "showConfirmacao('Confirma estorno da transferência a prejuízo?','Confirma&ccedil;&atilde;o - Ayllos','carregaPrejuizoCC(\'$nrdconta\', 1);','estadoInicial();','sim.gif','nao.gif');";
		exit();
	}else{
		// se confirmar
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0199.p</Bo>";
		$xml .= "		<Proc>grava_dados</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "		<nmdatela>".$nmdatela."</nmdatela>";
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
		$xml .= "		<dtdpagto>".$glbvars["dtmvtopr"]."</dtdpagto>";
		$xml .= "		<cdfinemp>".$cdfinemp."</cdfinemp>";
		$xml .= "		<cdlcremp>".$cdlcremp."</cdlcremp>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = getDataXML($xml,false);
		$xmlObj = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
		$xmlObj = simplexml_load_string($xmlResult);
	
		$error = $xmlObj->Erro->Registro->erro;
		if ($error == "yes"){
			$msgErro = utf8_decode($xmlObj->Erro->Registro->dscritic);
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}else{
			echo 'hideMsgAguardo();';
			echo 'showError("inform","Transferência a prejuízo de conta corrente efetuada com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}
	}
?>