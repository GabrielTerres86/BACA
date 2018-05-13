<?php 

	//************************************************************************//
	//*** Fonte: poupanca_incluir_validar.php                              ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 07/05/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar dados para incluir poupan�a programada       ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 07/05/2010 - Incluir o campo Tipo de impressao do    ***//
	//***						   extrato (Gabriel)					   ***//
	//***																   ***//
	//*** 			  03/01/2012 - Altera��o na fun��o 'exibeErro' para    ***//
	//***						   focar no campo (Lucas)   			   ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtinirpp"]) || !isset($_POST["diadtvct"]) ||
	    !isset($_POST["mesdtvct"]) || !isset($_POST["anodtvct"]) || !isset($_POST["vlprerpp"]) ||
		!isset($_POST["tpemiext"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	
	$nrdconta = $_POST["nrdconta"];
	$dtinirpp = $_POST["dtinirpp"];	
	$diadtvct = $_POST["diadtvct"];	
	$mesdtvct = $_POST["mesdtvct"];	
	$anodtvct = $_POST["anodtvct"];	
	$vlprerpp = $_POST["vlprerpp"];	
	$tpemiext = $_POST["tpemiext"];
	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a data de in�cio � v�lida
	if (!validaData($dtinirpp)) {
		exibeErro("Data de in&iacute;cio inv&aacute;lida.");
	}
	
	// Verifica se dia para vencimento � um inteiro v�lido
	if (!validaInteiro($diadtvct)) {
		exibeErro("Dia para vencimento inv&aacute;lido.");
	}
	
	// Verifica se m�s para vencimento � um inteiro v�lido
	if (!validaInteiro($mesdtvct)) {
		exibeErro("M&ecirc;s para vencimento inv&aacute;lido.");
	}

	// Verifica se ano para vencimento � um inteiro v�lido
	if (!validaInteiro($anodtvct)) {
		exibeErro("Ano para vencimento inv&aacute;lido.");
	}	
	
	// Verifica se a data de vencimento � v�lida
	if (!validaData($diadtvct."/".$mesdtvct."/".$anodtvct)) {
		exibeErro("Data de vencimento inv&aacute;lida.");
	}
	
	// Verifica se o valor da presta��o � um decimal v�lido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}		

	// Verifica se o tipo de impressao � um inteiro v�lido
	if (!validaInteiro($tpemiext))  {
		exibeErro("Tipo de impressao do extrato inv&aacute;lido.");	
	}	
	
	// Monta o xml de requisi��o
	$xmlIncluir  = ""; 
	$xmlIncluir .= "<Root>";
	$xmlIncluir .= "	<Cabecalho>";
	$xmlIncluir .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlIncluir .= "		<Proc>validar-dados-inclusao</Proc>";
	$xmlIncluir .= "	</Cabecalho>";	
	$xmlIncluir .= "	<Dados>";
	$xmlIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlIncluir .= "		<dtinirpp>".$dtinirpp."</dtinirpp>"; 			
	$xmlIncluir .= "		<mesdtvct>".$mesdtvct."</mesdtvct>";
	$xmlIncluir .= "		<anodtvct>".$anodtvct."</anodtvct>";	
	$xmlIncluir .= "		<vlprerpp>".$vlprerpp."</vlprerpp>"; 	
	$xmlIncluir .= "		<tpemiext>".$tpemiext."</tpemiext>";
	$xmlIncluir .= "	</Dados>";	
	$xmlIncluir .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlIncluir);

	// Cria objeto para classe de tratamento de XML
	$xmlObjIncluir = getObjectXML($xmlResult);
	
	
	$nmcampos = $xmlObjIncluir->roottag->tags[0]->attributes["NMCAMPOS"];
		
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata, $nmcampos);
		
	} 
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	// Confirma opera��o
	echo 'showConfirmacao("Deseja incluir a poupan&ccedil;a programada?","Confirma&ccedil;&atilde;o - Ayllos","incluirPoupanca(\''.$dtinirpp.'\',\''.$diadtvct.'\',\''.$mesdtvct.'\',\''.$anodtvct.'\',\''.$vlprerpp.'\' ,\''.$tpemiext.'\')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro, $campo) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","focaCampoErro(\"'.$campo.'\",\'frmDadosPoupanca\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); ");';
		exit();
		
	}
	
?>