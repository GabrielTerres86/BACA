<?php 

	/************************************************************************
	 Fonte: principal.php                                             
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                �ltima Altera��o: 14/07/2011     
	                                                                  
	 Objetivo  : Mostrar dados principais da rotina de relacionamento
	                                                                  	 
	 Altera��es: 03/11/2010 - Alimentar campo dtcadqst (David).
				
				 09/02/2011 - Corrigir alimentacao do campo Historico (Gabriel). 

				14/07/2011 - Alterado para layout padr�o (Rogerius - DB1). 	
				 
	***********************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi��o
	$xmlGetDadosRelacionamento  = "";
	$xmlGetDadosRelacionamento .= "<Root>";
	$xmlGetDadosRelacionamento .= "	<Cabecalho>";
	$xmlGetDadosRelacionamento .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosRelacionamento .= "		<Proc>obtem-quantidade-eventos</Proc>";
	$xmlGetDadosRelacionamento .= "	</Cabecalho>";
	$xmlGetDadosRelacionamento .= "	<Dados>";
	$xmlGetDadosRelacionamento .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosRelacionamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosRelacionamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosRelacionamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosRelacionamento .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosRelacionamento .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDadosRelacionamento .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosRelacionamento .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosRelacionamento .= "	</Dados>";
	$xmlGetDadosRelacionamento .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosRelacionamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosRelacionamento = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosRelacionamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosRelacionamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDadosRelacionamento->roottag->tags[0]->tags[0]->tags;
	
	$dtinique = getByTagName($dados,"DTINIQUE");
	$dtfimque = getByTagName($dados,"DTFIMQUE");
	
	// Mostra dados da senha de Tele Atendimento nos campos
	echo '$("#qtpenden","#frmRelacionamento").val("'.getByTagName($dados,"QTPENDEN").'");';
	echo '$("#qtconfir","#frmRelacionamento").val("'.getByTagName($dados,"QTCONFIR").'");';
	echo '$("#qtandame","#frmRelacionamento").val("'.getByTagName($dados,"QTANDAME").'");';
	echo '$("#qthistor","#frmRelacionamento").val("'.getByTagName($dados,"QTHISPAR").'");';
	echo '$("#dtinique","#frmRelacionamento").val("'.$dtinique.'");';	
	echo '$("#dtfimque","#frmRelacionamento").val("'.$dtfimque.'");';
	echo '$("#dtinique","#frmRelacionamentoQuestionario").val("'.$dtinique.'");';	
	echo '$("#dtfimque","#frmRelacionamentoQuestionario").val("'.$dtfimque.'");';
	echo '$("#dtcadqst","#frmRelacionamentoQuestionario").val("'.getByTagName($dados,"DTCADQST").'");';

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Configura visualiza��o dos divs
	echo '$("#divConteudoOpcao").css("display","block");';
	echo '$("#divRelacionamentoPrincipal").css("display","block");';
	echo '$("#divOpcoesDaOpcao1").css("display","none");';
	echo '$("#divOpcoesDaOpcao2").css("display","none");';
	echo '$("#divRelacionamentoQuestionario").css("display","none");';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>