<? 
/*!
 * FONTE        : estornar_pagto.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : Rotina para estornar o pagamento selecionado
 * --------------
 * ALTERAÇÕES   : 02/01/2017: Confirmação de estorno. Andrey Formigari - Mouts
 * -------------- 
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();		

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> ''){
	exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}
	
$nrdconta1 = (isset($_POST['nrdconta1'])) ? $_POST['nrdconta1'] : 0;
$nrctremp1 = (isset($_POST['nrctremp1'])) ? $_POST['nrctremp1'] : 0;
$dtmvtolt = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : "01/01/0001";
$idtipo = (isset($_POST['idtipo'])) ? $_POST['idtipo'] : '';
$okConfirm = (isset($_POST['okConfirm'])) ? $_POST['okConfirm'] : '';

// se não confirmou o estorno, então abre tela para confirmar.
if ($okConfirm != 1){	
	echo 'hideMsgAguardo();';
	echo "showConfirmacao('Confirmar estorno do pagamento?','Confirma&ccedil;&atilde;o - Ayllos','carregaTelaEstornar(\'$nrdconta1\', \'$nrctremp1\', \'$dtmvtolt\', \'$idtipo\', 1);','estadoInicial();','sim.gif','nao.gif');";
	exit();
}else{
	// se confirmou estorno, processa.
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta1."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp1."</nrctremp>";	
	$xml .= "   <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	$xml .= "   <idtipo>".$idtipo."</idtipo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ESTPRJ", "DESFAZ_PAGTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	$xmlObj = simplexml_load_string($xmlResult);
	
	$error = $xmlObj->Erro->Registro->erro;
	if ($error == "yes"){
		$msgErro = $xmlObj->Erro->Registro->dscritic;
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.utf8_decode($msgErro).'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagto\').focus();");';
		exit();
	}else{		
		echo 'hideMsgAguardo();';
		//echo 'showError("inform","Estorno de pagamento efetuado com sucesso.","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagto\').focus();");';
		echo 'showError("inform","Estorno de pagamento efetuado com sucesso.","Alerta - Ayllos","estadoInicial();");';
		exit();
	}
}
?>