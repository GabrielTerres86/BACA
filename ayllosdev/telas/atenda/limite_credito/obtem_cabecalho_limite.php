<?php
/*!
 * FONTE        : obtem_cabecalho_limite.php
 * CRIA��O      : Tiago Machado       
 * DATA CRIA��O : 28/01/2015
 * OBJETIVO     : Rotina para gera��o de relatorios da tela debtar.
 * --------------
 * ALTERA��ES   :  08/07/2015 - Tratamento de caracteres especiais e remover quebra de linha da observa��o (Lunelli - SD SD 300819 | 300893) 
 * -------------- 
 */
 ?>
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');		
	isPostMethod();	
	
	// Verifica se os par�metros necess�rios foram informados
	$params = array('nrdconta', 'redirect');

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);			
	}

	$nrdconta = $_POST['nrdconta'];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
	

	// Monta o xml de requisi��o
	$xmlGetLimite  = "";
	$xmlGetLimite .= "<Root>";
	$xmlGetLimite .= "	<Cabecalho>";
	$xmlGetLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGetLimite .= "		<Proc>obtem-cabecalho-limite</Proc>";
	$xmlGetLimite .= "	</Cabecalho>";
	$xmlGetLimite .= "	<Dados>";
	$xmlGetLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLimite .= "		<idseqttl>1</idseqttl>";
	$xmlGetLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetLimite .= "	</Dados>";
	$xmlGetLimite .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$limite = $xmlObjLimite->roottag->tags[0]->tags[0]->tags;
	$dsobserv = getByTagName($limite,'dsobserv');
	$dsobserv = removeCaracteresInvalidos($dsobserv);
	
	echo 'setDadosObservacao("'.$dsobserv.'");';

?>