<?php 

	/**********************************************************************
	  Fonte: entregar_valida_entrega.php
	  Autor: Guilherme
	  Data : Abri/2007            			�ltima Altera��o: 21/05/2014

      Objetivo  : Valida entrega Cart�o de Cr�dito - rotina de Cart�o
	              de Cr�dito da tela ATENDA

	  Altera��es: 14/05/2009 - Alterar nome dtvalchr para dtvalida (David)
	  
	              04/11/2010 - Adapta��o Cart�o PJ (David)
				  
				  21/05/2014 - Alterar para chamar a funcao "efetuaEntregaCartaoNormal" (James)
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
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"])  || !isset($_POST["nrctrcrd"]) || !isset($_POST["nrcrcard"]) || 
	    !isset($_POST["nrcrcard2"]) || !isset($_POST["dtvalida"]) || !isset($_POST["repsolic"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta  = $_POST["nrdconta"];
	$nrctrcrd  = $_POST["nrctrcrd"];
	$repsolic  = $_POST["repsolic"];
	$nrcrcard  = $_POST["nrcrcard"];
	$nrcrcard2 = $_POST["nrcrcard2"];
	$dtvalida  = $_POST["dtvalida"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se n�mero do cart�o � um inteiro v�lido
	if (!validaInteiro($nrcrcard)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	

	// Verifica se n�mero do cart�o � um inteiro v�lido
	if (!validaInteiro($nrcrcard2)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
	// Verifica se data de validade � um inteiro v�lido
	if (!validaInteiro($dtvalida)) {
		exibeErro("Data de validade inv&aacute;lida.");
	}

	// Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_entrega_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<inconfir>2</inconfir>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<nrcrcard2>".$nrcrcard2."</nrcrcard2>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$mensagem = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;

	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	if ($mensagem == "") {		
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';				
	} else {
		// Confirma se deseja mesmo efetuar a libera��o
		echo 'showConfirmacao("'.$mensagem.'","Confirma&ccedil;&atilde;o - Aimaro","efetuaEntregaCartaoNormal()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>