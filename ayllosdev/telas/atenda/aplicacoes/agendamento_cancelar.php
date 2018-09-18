<?php 

	//************************************************************************//
	//*** Fonte: agendamento_cancelar.php                                  ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Setembro/2014                �ltima Altera��o: 21/07/2016 ***//
	//***                                                                  ***//
	//*** Objetivo  : Cancelar o agendamento de aplica��o e  resgate       ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 21/07/2016 Corrigi a forma de validacao do retorno   ***//	
	//***						 XML"ERRO".SD 479874 (Carlos R.)		   ***//
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctraar"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctraar = $_POST["nrctraar"];

	// Verifica se n�mero do agendamento � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	// Verifica se n�mero do agendamento � um inteiro v�lido
	if (!validaInteiro($nrctraar)) {
		exibeErro("N&uacute;mero do agendamento inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
	$xmlAgendamento  = "";
	$xmlAgendamento .= "<Root>";
	$xmlAgendamento .= "	<Cabecalho>";
	$xmlAgendamento .= "		<Bo>b1wgen0081.p</Bo>";
	$xmlAgendamento .= "		<Proc>excluir-agendamento</Proc>";
	$xmlAgendamento .= "	</Cabecalho>";
	$xmlAgendamento .= "	<Dados>";
	$xmlAgendamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAgendamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAgendamento .= "		<idseqttl>1</idseqttl>";
	$xmlAgendamento .= "		<nrctraar>".$nrctraar."</nrctraar>";
	$xmlAgendamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAgendamento .= "	</Dados>";
	$xmlAgendamento .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAgendamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAgendamento = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjAgendamento->roottag->tags[0]->name) && strtoupper($xmlObjAgendamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAgendamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	// Bloqueia conte�do que est� atr�s do div da rotina
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Voltar para op��o geral de agendamento
	echo 'recarregaAgendamento();';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>