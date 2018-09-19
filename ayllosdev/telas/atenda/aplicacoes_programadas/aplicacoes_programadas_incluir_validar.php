<?php 

	/***************************************************************************
	 Fonte: aplicacoes_programadas_incluir_validar.php                             
	 Autor: David                                                     
	 Data : Mar�o/2010                   �ltima Altera��o: 27/07/2018
	                                                                  
	 Objetivo  : Validar dados para incluir poupan�a programada     
	                                                                  
	 Altera��es: 07/05/2010 - Incluir o campo Tipo de impressao do extrato (Gabriel)
	 
				 03/01/2012 - Altera��o na fun��o 'exibeErro' para focar no campo (Lucas)
	 
	             26/07/2016 - Tratei o retorno XML de erro. SD 479874 (Carlos R.)

				 04/04/2018 - Chamada da rotina para verificar o range permitido para 
				              contrata��o do produto. PRJ366 (Lombardi).

				 27/07/2018 - Deriva��o para Aplica��o Programada 
							  (Proj. 411.2 - CIS Corporate)                   
				 
	***************************************************************************/
	
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
		!isset($_POST["tpemiext"]) || !isset($_POST["cdprodut"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$dtinirpp = $_POST["dtinirpp"];	
	$diadtvct = $_POST["diadtvct"];	
	$mesdtvct = $_POST["mesdtvct"];	
	$anodtvct = $_POST["anodtvct"];	
	$vlprerpp = $_POST["vlprerpp"];	
	$tpemiext = $_POST["tpemiext"];
	$cdprodut = $_POST["cdprodut"];

	
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
	
	// Verifica se o produto � v�lido
	if (!validaInteiro($cdprodut) || $cdprodut < 1 ) {
		exibeErro("Aplica&ccedil;&atilde;o programada inv&aacute;lida.");			
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
	
	
	$nmcampos = ( isset($xmlObjIncluir->roottag->tags[0]->attributes["NMCAMPOS"]) ) ? $xmlObjIncluir->roottag->tags[0]->attributes["NMCAMPOS"] : '';
		
	
	// Se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjIncluir->roottag->tags[0]->name) && strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata, $nmcampos);
	} 
	
	$vlcontra = str_replace(',','.',str_replace('.','',$vlprerpp));
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>".    16   ."</cdprodut>"; //Poupan�a Programada
	$xml .= "   <vlcontra>".$vlcontra."</vlcontra>";
	$xml .= "   <cddchave>".    0    ."</cddchave>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','',false);
	}
	
	$solcoord = $xmlObject->roottag->tags[0]->cdata;
	$mensagem = $xmlObject->roottag->tags[1]->cdata;
	
	$executar = "";
	
	// Esconde mensagem de aguardo
	$executar .= "hideMsgAguardo();";	
	
	// Confirma opera��o
	$executar .= "showConfirmacao(\"Deseja incluir a poupan&ccedil;a programada?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"incluirAplProg(\\\"".$dtinirpp."\\\",\\\"".$diadtvct."\\\",\\\"".$mesdtvct."\\\",\\\"".$anodtvct."\\\",\\\"".$vlprerpp."\\\" ,\\\"".$tpemiext."\\\")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
	
	// Se ocorrer um erro, mostra cr�tica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Aimaro", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro, $campo) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","focaCampoErro(\"'.$campo.'\",\'frmDadosPoupanca\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); ");';
		exit();
		
	}
	
?>