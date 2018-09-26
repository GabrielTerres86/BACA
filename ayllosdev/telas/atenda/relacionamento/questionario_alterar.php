<?php 

	/************************************************************************
	 Fonte: questionario_alterar.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                     Última Alteração: 27/07/2016   
	                                                                  
	 Objetivo  : Alterar datas de entrega/devolução do questionário
	                                                                  	 
	 Alterações: 25/10/2010 - Adicionar validação de permissão (David).                                                      
				 27/07/2016 - Corrigi o retorno XML erro. SD 479874 (Carlos R.)                                                   
	************************************************************************/

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["dtinique"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtinique = $_POST["dtinique"];
	$dtfimque = $_POST["dtfimque"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
		
	// Verifica se o código do motivo é um inteiro válido
	if (!validaData($dtinique)) {
		exibeErro("Data de entrega do question&aacute;rio inv&aacute;lida.");
	}
	
	if ($dtfimque != "" && !validaData($dtfimque)) {
		exibeErro("Data de devolu&ccedil;&atilde;o do question&aacute;rio inv&aacute;lida.");
	}	
		
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjDadosQuestionario->roottag->tags[0]->name) && strtoupper($xmlObjDadosQuestionario->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosQuestionario->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';

	echo 'acessaOpcaoPrincipal();';
	
	// Função para exibir erros na tela atravé de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>