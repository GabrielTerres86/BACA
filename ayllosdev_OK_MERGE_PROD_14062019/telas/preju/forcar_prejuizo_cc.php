<? 
/*!
 * FONTE        : forcar_prejuizo_cc.php
 * CRIA��O      : Jean Calao (Mout�S)
 * DATA CRIA��O : 05/07/2017
 * OBJETIVO     : Rotina para for�ar transferencia de conta corrente para prejuizo
 * --------------
 * ALTERA��ES   : 03/01/2017: Confirma��o de estorno. Andrey Formigari - Mouts
 *                25/07/2018: Adapta��o para uso da nova rotina de transfer�ncia para preju�zo. 
                              Reginaldo - AMcom - P450
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
	
	// se n�o confirmou o estorno, ent�o abre tela para confirmar.
	if ($okConfirm != 1){
		echo 'hideMsgAguardo();';
		echo "showConfirmacao('Confirma transfer�ncia da conta corrente para preju�zo?','Confirma&ccedil;&atilde;o - Aimaro','carregaPrejuizoCC(\'$nrdconta\', 1);','estadoInicial();','sim.gif','nao.gif');";
		exit();
	}else{
		// Monta o xml de requisi��o
		$xml = "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		
		$xmlResult = mensageria($xml, "PREJ0003", "TRANSF_PREJUIZO_CC", 
			$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
			$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>"); 

		$xmlObjeto = getObjectXML($xmlResult);
	
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',addslashes(utf8_encode($msgErro)),'Alerta - Ayllos','unblockBackground()',false);
		}else{
			echo 'hideMsgAguardo();';
			echo 'showError("inform","Transfer�ncia a preju�zo de conta corrente efetuada com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
			exit();
		}
	}
?>