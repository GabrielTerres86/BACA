<?php 

	/***************************************************************************
	 Fonte: entrega_talonarios.php
	 Autor: Lombardi
 	 Data : Agosto/2018                 Última Alteração: 16/08/2018

	 Objetivo  : Rotina de entrega de talonarios

	 Alterações: 29/11/2018 - Adicionado campo qtreqtal. Acelera - Entrega de Talonario (Lombardi)
				
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	include("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E',false)) <> '') 
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$nrdconta = isset($_POST['nrdconta']) && $_POST['nrdconta'] != '' ? $_POST['nrdconta'] : 0;
	$tprequis = isset($_POST['tprequis']) && $_POST['tprequis'] != '' ? $_POST['tprequis'] : 0;
	$nrinichq = isset($_POST['nrinichq']) && $_POST['nrinichq'] != '' ? $_POST['nrinichq'] : 0;
	$nrfinchq = isset($_POST['nrfinchq']) && $_POST['nrfinchq'] != '' ? $_POST['nrfinchq'] : 0;
	$terceiro = isset($_POST['terceiro']) && $_POST['terceiro'] != '' ? $_POST['terceiro'] : 0;
	$cpfterce = isset($_POST['cpfterce']) && $_POST['cpfterce'] != '' ? $_POST['cpfterce'] : 0;
	$nmtercei = isset($_POST['nmtercei']) && $_POST['nmtercei'] != '' ? $_POST['nmtercei'] : '';
	$nrtaloes = isset($_POST['nrtaloes']) && $_POST['nrtaloes'] != '' ? $_POST['nrtaloes'] : '';
	$qtreqtal = isset($_POST['qtreqtal']) && $_POST['qtreqtal'] != '' ? $_POST['qtreqtal'] : 0;
	$verifica = isset($_POST['verifica']) && $_POST['verifica'] != '' ? $_POST['verifica'] : 1;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<tprequis>".$tprequis."</tprequis>";
	$xml .= "		<nrinichq>".$nrinichq."</nrinichq>";
	$xml .= "		<nrfinchq>".$nrfinchq."</nrfinchq>";
	$xml .= "		<terceiro>".$terceiro."</terceiro>";
	$xml .= "		<cpfterce>".$cpfterce."</cpfterce>";
	$xml .= "		<nmtercei>".$nmtercei."</nmtercei>";
	$xml .= "		<nrtaloes>".$nrtaloes."</nrtaloes>";
	$xml .= "		<qtreqtal>".$qtreqtal."</qtreqtal>";
	$xml .= "		<verifica>".$verifica."</verifica>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CHEQ0001", "CHQ_ENTREGA_TALONARIO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	if ($verifica == 1) {
		if ($terceiro == 1)
			$executa = "entregaTalonario(0);";
		else
			$executa = "solicitaSenhaMagnetico(\"entregaTalonario(0)\",".$nrdconta.",\"s\")";
		echo $executa;
	} else {
		exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Aimaro','voltarConteudo(\'divConteudoOpcao\',\'divTalionario\');bloqueiaFundo(divRotina)',false);
	}
?>