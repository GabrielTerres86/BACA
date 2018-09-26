<?php 

	//*************************************************************************//
	//*** Fonte: validar_senha.php                                          ***//
	//*** Autor: James Prust Junior                                         ***//
	//*** Data : Julho/2015                   Ultima Alteração: 00/00/0000  ***//
	//***                                                                   ***//
	//*** Objetivo:  Validação da senha do cartão magnético			        ***//
	//***                                                                   ***//	 
	//*** Alterações: 													    ***//    
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || 
		!isset($_POST["nrsenatu"]) || !isset($_POST["nrsencar"]) || 
		!isset($_POST["nrsencon"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$nrsenatu = $_POST["nrsenatu"];
	$nrsencar = $_POST["nrsencar"];
	$nrsencon = $_POST["nrsencon"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibirErro('error','N&uacute;mero do cart&atilde;o inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetSenha  = "";
	$xmlSetSenha .= "<Root>";
	$xmlSetSenha .= "	<Cabecalho>";
	$xmlSetSenha .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlSetSenha .= "		<Proc>validar-senha-cartao-magnetico</Proc>";
	$xmlSetSenha .= "	</Cabecalho>";
	$xmlSetSenha .= "	<Dados>";
	$xmlSetSenha .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetSenha .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetSenha .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetSenha .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetSenha .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetSenha .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetSenha .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetSenha .= "		<idseqttl>1</idseqttl>";
	$xmlSetSenha .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetSenha .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlSetSenha .= "		<nrsenatu>".$nrsenatu."</nrsenatu>";
	$xmlSetSenha .= "		<nrsencar>".$nrsencar."</nrsencar>";
	$xmlSetSenha .= "		<nrsencon>".$nrsencon."</nrsencon>";
	$xmlSetSenha .= "	</Dados>";
	$xmlSetSenha .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetSenha);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSenha = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSenha->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjSenha->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}
	echo 'abreTelaLimiteSaque();';
?>