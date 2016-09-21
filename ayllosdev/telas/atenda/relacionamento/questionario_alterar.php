<?php 

	/************************************************************************
	 Fonte: questionario_alterar.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                     �ltima Altera��o: 25/10/2010     
	                                                                  
	 Objetivo  : Alterar datas de entrega/devolu��o do question�rio
	                                                                  	 
	 Altera��es: 25/10/2010 - Adicionar valida��o de permiss�o (David).                                                      
	************************************************************************/

	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["dtinique"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtinique = $_POST["dtinique"];
	$dtfimque = $_POST["dtfimque"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
		
	// Verifica se o c�digo do motivo � um inteiro v�lido
	if (!validaData($dtinique)) {
		exibeErro("Data de entrega do question&aacute;rio inv&aacute;lida.");
	}
	
	if ($dtfimque != "" && !validaData($dtfimque)) {
		exibeErro("Data de devolu&ccedil;&atilde;o do question&aacute;rio inv&aacute;lida.");
	}	
		
	// Monta o xml de requisi��o
	$xmlGetDadosQuestionario  = "";
	$xmlGetDadosQuestionario .= "<Root>";
	$xmlGetDadosQuestionario .= "	<Cabecalho>";
	$xmlGetDadosQuestionario .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosQuestionario .= "		<Proc>grava-data-questionario</Proc>";
	$xmlGetDadosQuestionario .= "	</Cabecalho>";
	$xmlGetDadosQuestionario .= "	<Dados>";
	$xmlGetDadosQuestionario .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosQuestionario .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosQuestionario .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosQuestionario .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosQuestionario .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosQuestionario .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDadosQuestionario .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosQuestionario .= "		<dtinique>".$dtinique."</dtinique>";
	$xmlGetDadosQuestionario .= "		<dtfimque>".$dtfimque."</dtfimque>";
	$xmlGetDadosQuestionario .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosQuestionario .= "	</Dados>";
	$xmlGetDadosQuestionario .= "</Root>";
			
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosQuestionario);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosQuestionario = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosQuestionario->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosQuestionario->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';

	echo 'acessaOpcaoPrincipal();';
	
	// Fun��o para exibir erros na tela atrav� de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>