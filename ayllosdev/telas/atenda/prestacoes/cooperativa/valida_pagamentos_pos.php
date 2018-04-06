<? 
/*!
 * FONTE        : valida_pagamentos_pos.php
 * CRIAÇÃO      : Jaison Fernando
 * DATA CRIAÇÃO : 21/07/2017
 * OBJETIVO     : Valida dados do pagamento
 *
 * ALTERACOES	: 
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos');
	}
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	$vlapagar = (isset($_POST['vlapagar'])) ? $_POST['vlapagar'] : '';

	// Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "		<vlapagar>".$vlapagar."</vlapagar>";
    $xml .= "	</Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "EMPR0011", "EMPR0011_VALIDA_PAG_POS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
        exibirErro('error',$xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	} else if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'CONFIRMACAO' ) {
		echo 'showConfirmacao("'.$xmlObject->roottag->tags[0]->cdata.'","Confirma&ccedil;&atilde;o - Ayllos","verificaAbreTelaPagamentoAvalista();","hideMsgAguardo();bloqueiaFundo(divRotina);","sim.gif","nao.gif");';
	} else {	
		echo 'confirmaPagamento();'; 
	}
?>