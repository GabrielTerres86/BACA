<?php 
	
	//************************************************************************//
	//*** Fonte: cadastrar_solicitacao.php                                 ***//
	//*** Autor: Fabr�cio                                                  ***//
	//*** Data : Setembro/2011                �ltima Altera��o: 06/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Cadastrar solicita��o de 2� via de senha e/ou cart�o ***//	
	//***             do benef�cio do INSS.                                ***//	 
	//*** Altera��es: 22/12/2011 - trocado parametro fixo pelo parametro   ***//
	//***                          global "idorigem"				       ***//
	//***															       ***//
	//***             31/01/2012 - Correcoes tarefa 42237 (Tiago)		   ***//
	//***                          									       ***//
	//***			  06/07/2012 - retirado var post imprimir (Jorge).     ***//
	//***			  15/08/2013 - Altera��o da sigla PAC para PA (Carlos) ***//
	//************************************************************************//
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$nmarqpdf = $_POST["nmarqpdf"];
	$cdagenci = $_POST["cdagenci"];
	$nridtrab = $_POST["nridtrab"];
	$nrbenefi = $_POST["nrbenefi"];	
	$cddopcao = $_POST["cddopcao"];
	$motivsol = $_POST["motivsol"];
	$nmbenefi = $_POST["nmbenefi"];
	$dsiduser = session_id();
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["cdagenci"]) || !isset($_POST["nridtrab"]) || !isset($_POST["nrbenefi"]) || !isset($_POST["cddopcao"]) || !isset($_POST["motivsol"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	// Verifica se o n�mero do PA � um inteiro v�lido
	if (!validaInteiro($cdagenci)) {
		exibeErro("PA inv&aacute;lido.");
	}	
	
	// Verifica se NIT � um inteiro v�lido
	if (!validaInteiro($nridtrab)) {
		exibeErro("NIT inv&aacute;lido.");
	}	
	
	// Verifica se NB � um inteiro v�lido
	if (!validaInteiro($nrbenefi)) {
		exibeErro("NB inv&aacute;lido.");
	}				
	
	// Verifica se o c�digo da op��o � um inteiro v�lido
	if (!validaInteiro($cddopcao)) {
		exibeErro("Op&ccedil;&atilde;o inv&aacute;lida.");
	}
	
	// Verifica se o c�digo do motivo da solicita��o � um inteiro v�lido
	if (!validaInteiro($motivsol)) {
		exibeErro("Motivo da solicita&ccedil;&atilde;o inv&aacute;lido.");
	}		
			
	// Monta o xml de requisi��o
	$xmlSolicitacao  = "";
	$xmlSolicitacao .= "<Root>";
	$xmlSolicitacao .= "	<Cabecalho>";
	$xmlSolicitacao .= "		<Bo>b1wgen0113.p</Bo>";
	$xmlSolicitacao .= "		<Proc>cadastra_solicitacao</Proc>";
	$xmlSolicitacao .= "	</Cabecalho>";
	$xmlSolicitacao .= "	<Dados>";
	$xmlSolicitacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSolicitacao .= "		<cdagenci>".$cdagenci."</cdagenci>";	
	$xmlSolicitacao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSolicitacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSolicitacao .= "		<nridtrab>".$nridtrab."</nridtrab>";
	$xmlSolicitacao .= "		<nrbenefi>".$nrbenefi."</nrbenefi>";
	$xmlSolicitacao .= "        <nmbenefi>".$nmbenefi."</nmbenefi>";
	$xmlSolicitacao .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitacao .= "		<motivsol>".$motivsol."</motivsol>";		
	$xmlSolicitacao .= "		<dsiduser>".$dsiduser."</dsiduser>";		
	$xmlSolicitacao .= "	</Dados>";
	$xmlSolicitacao .= "</Root>";			
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSolicitacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSolicitacao = getObjectXML($xmlResult);
	
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjSolicitacao->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Verifica se foi retornado algum erro
	$dscritic = $xmlObjSolicitacao->roottag->tags[0]->attributes["DSCRITIC"];
	
	if ($dscritic != ""){		    
		exibeErro($dscritic);
	}
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
?>