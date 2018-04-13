<?php 

	/***************************************************************************
	 Fonte: poupanca_incluir_validar.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 04/04/2018
	                                                                  
	 Objetivo  : Validar dados para incluir poupança programada     
	                                                                  
	 Alterações: 07/05/2010 - Incluir o campo Tipo de impressao do extrato (Gabriel)
	 
				 03/01/2012 - Alteração na função 'exibeErro' para focar no campo (Lucas)
	 
				 04/04/2018 - Chamada da rotina para verificar o range permitido para 
				              contratação do produto. PRJ366 (Lombardi).
				 
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
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
	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a data de início é válida
	if (!validaData($dtinirpp)) {
		exibeErro("Data de in&iacute;cio inv&aacute;lida.");
	}
	
	// Verifica se dia para vencimento é um inteiro válido
	if (!validaInteiro($diadtvct)) {
		exibeErro("Dia para vencimento inv&aacute;lido.");
	}
	
	// Verifica se mês para vencimento é um inteiro válido
	if (!validaInteiro($mesdtvct)) {
		exibeErro("M&ecirc;s para vencimento inv&aacute;lido.");
	}

	// Verifica se ano para vencimento é um inteiro válido
	if (!validaInteiro($anodtvct)) {
		exibeErro("Ano para vencimento inv&aacute;lido.");
	}	
	
	// Verifica se a data de vencimento é válida
	if (!validaData($diadtvct."/".$mesdtvct."/".$anodtvct)) {
		exibeErro("Data de vencimento inv&aacute;lida.");
	}
	
	// Verifica se o valor da prestação é um decimal válido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}		

	// Verifica se o tipo de impressao é um inteiro válido
	if (!validaInteiro($tpemiext))  {
		exibeErro("Tipo de impressao do extrato inv&aacute;lido.");	
	}	
	
	// Monta o xml de requisição
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
		
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata, $nmcampos);
		
	} 
	
	$vlprerpp = str_replace(',','.',str_replace('.','',$vlprerpp));
	
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>".    16   ."</cdprodut>"; //Poupança Programada
	$xml .= "   <vlcontra>".$vlprerpp."</vlcontra>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_VALOR_ADESAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	$solcoord = $xmlObject->roottag->tags[0]->cdata;
	$mensagem = $xmlObject->roottag->tags[1]->cdata;
	
	$executar = "";
	
	// Esconde mensagem de aguardo
	$executar .= "hideMsgAguardo();";	
	
	// Confirma operação
	$executar .= "showConfirmacao(\"Deseja incluir a poupan&ccedil;a programada?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"incluirPoupanca(\\\"".$dtinirpp."\\\",\\\"".$diadtvct."\\\",\\\"".$mesdtvct."\\\",\\\"".$anodtvct."\\\",\\\"".$vlprerpp."\\\" ,\\\"".$tpemiext."\\\")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
	
	// Se ocorrer um erro, mostra crítica
	if ($mensagem != "") {
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$mensagem,"Alerta - Ayllos", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
	} else {
		echo $executar;
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro, $campo) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","focaCampoErro(\"'.$campo.'\",\'frmDadosPoupanca\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\'))); ");';
		exit();
		
	}
	
?>