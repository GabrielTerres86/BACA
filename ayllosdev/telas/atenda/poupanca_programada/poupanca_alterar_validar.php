<?php 

	/***************************************************************************
	 Fonte: poupanca_alterar_validar.php                             
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 04/04/2018
	                                                                  
	 Objetivo  : Validar dados para alterar poupança programada     
	                                                                  
	 Alterações: 04/04/2018 - Chamada da rotina para verificar o range permitido para 
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"]) || !isset($_POST["vlprerpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];	
	$vlprerpp = $_POST["vlprerpp"];	
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
	
	// Verifica se o valor da prestação é um decimal válido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}					
	
	// Monta o xml de requisição
	$xmlAlterar  = ""; 
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "	<Cabecalho>";
	$xmlAlterar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlAlterar .= "		<Proc>validar-dados-alteracao</Proc>";
	$xmlAlterar .= "	</Cabecalho>";	
	$xmlAlterar .= "	<Dados>";
	$xmlAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "		<idseqttl>1</idseqttl>";
	$xmlAlterar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>"; 			
	$xmlAlterar .= "		<vlprerpp>".$vlprerpp."</vlprerpp>"; 	
	$xmlAlterar .= "	</Dados>";	
	$xmlAlterar .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAlterar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
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
	$executar .= "showConfirmacao(\"Deseja alterar a poupan&ccedil;a programada?\",\"Confirma&ccedil;&atilde;o - Ayllos\",\"alterarPoupanca(\\\"".$vlprerpp."\\\")\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
	
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
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>