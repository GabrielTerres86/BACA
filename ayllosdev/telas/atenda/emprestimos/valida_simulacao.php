<?php
/*!
 * FONTE        : valida_novo_calculo.php
 * CRIA��O      : Marcelo L. Pereira (GATI)
 * DATA CRIA��O : 16/11/2011 
 * OBJETIVO     : Faz verifica��o para a tela de simula��o
 *
 * ALTERACAO: 19/07/2016 - Correcao da passagem incorreta da variavel idseqttl para xb1wgen0097. SD 479874. (Carlos R.)
 *
 *            30/11/2016 - P341-Automatiza��o BACENJUD - Alterado para passar como parametro o c�digo do departamento
 *                         ao inv�s da descri��o (Renato Darosci - Supero)
 *
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os par�metos do POST em vari�veis	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '1';
			
	// Monta o xml de requisi��o
	$xml = '';
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0097.p</Bo>";
	$xml .= "		<Proc>valida_simulacao</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<flgerlog>FALSE</flgerlog>";
	$xml .= "		<cddepart>".$glbvars["cddepart"]."</cddepart>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'))',false);
	}
	echo 'mostraTabelaSimulacao(\'TS\');';
?>