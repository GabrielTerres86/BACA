<?php 

	//************************************************************************//
	//*** Fonte: agendamento_excluir_detalhe.php                           ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Setembro/2014                �ltima Altera��o:   /  /     ***//
	//***                                                                  ***//
	//*** Objetivo  : Excluir o detalhe do agendamento de aplica��o e      ***//	
	//***             resgate                                              ***//	
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["flgtipar"]) || !isset($_POST["nrdocmto"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = ( isset($_POST["nrdconta"]) ) ? $_POST["nrdconta"] : null;
	$flgtipar = ( isset($_POST["flgtipar"]) ) ? $_POST["flgtipar"] : null;
	$nrdocmto = ( isset($_POST["nrdocmto"]) ) ? $_POST["nrdocmto"] : null;
	
	// Verifica se n�mero do agendamento � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	// Verifica se n�mero do agendamento � um inteiro v�lido
	if (!validaInteiro($nrdocmto)) {
		exibeErro("N&uacute;mero do documento inv&aacute;lido.");
	}	
	
	// Verifica se tipo de agendamendo � v�lido
	if (!validaInteiro($flgtipar) || $flgtipar < 0 || $flgtipar > 1) {
		exibeErro("Tipo de agendamento inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
	$xmlExcluiDetAgen  = "";
	$xmlExcluiDetAgen .= "<Root>";
	$xmlExcluiDetAgen .= "	<Cabecalho>";
	$xmlExcluiDetAgen .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlExcluiDetAgen .= "		<Proc>excluir-agendamento-det</Proc>";
	$xmlExcluiDetAgen .= "	</Cabecalho>";
	$xmlExcluiDetAgen .= "	<Dados>";
	$xmlExcluiDetAgen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluiDetAgen .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluiDetAgen .= "		<idseqttl>1</idseqttl>";
	$xmlExcluiDetAgen .= "		<flgtipar>".$flgtipar."</flgtipar>";
	$xmlExcluiDetAgen .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlExcluiDetAgen .= "	</Dados>";
	$xmlExcluiDetAgen .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluiDetAgen);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResult = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjResult->roottag->tags[0]->name) && strtoupper($xmlObjResult->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResult->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	// Bloqueia conte�do que est� atr�s do div da rotina
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recarrega os detalhes do agendamento que foi selecionado
	echo 'detalhesAgendamento();';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>