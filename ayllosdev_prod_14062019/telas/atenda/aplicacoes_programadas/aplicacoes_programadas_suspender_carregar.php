<?php 

	//**************************************************************************************//
	//*** Fonte: aplicacoes_programadas_suspender_carregar.php                           ***//
	//*** Autor: David                                                                   ***//
	//*** Data : Março/2010                   Ultima Alteracao: 27/07/2018               ***//
	//***                                                                                ***//
	//*** Objetivo  : Mostrar opção para suspender Aplicação Programada                  ***//	
	//***                                                                                ***//	 
	//*** Alterações: 27/07/2018 - Derivação para Aplicação Programada                   ***//
	//***                     	   (Proj. 411.2 - CIS Corporate)                         ***// 
	//**************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	

	/*	
	// Monta o xml de requisição
	$xmlSuspender  = "";
	$xmlSuspender .= "<Root>";
	$xmlSuspender .= "	<Cabecalho>";
	$xmlSuspender .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlSuspender .= "		<Proc>obtem-dados-suspensao</Proc>";
	$xmlSuspender .= "	</Cabecalho>";
	$xmlSuspender .= "	<Dados>";
	$xmlSuspender .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSuspender .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSuspender .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSuspender .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSuspender .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSuspender .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSuspender .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSuspender .= "		<idseqttl>1</idseqttl>";
	$xmlSuspender .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlSuspender .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSuspender .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlSuspender .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlSuspender .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlSuspender .= "	</Dados>";
	$xmlSuspender .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSuspender);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSuspender = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSuspender->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSuspender->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	*/
	// Montar o xml de Requisicao
	$xmlSuspender = "<Root>";
	$xmlSuspender .= " <Dados>";
	$xmlSuspender .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSuspender .= "	<idseqttl>1</idseqttl>";
	$xmlSuspender .= "	<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlSuspender .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSuspender .= "	<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlSuspender .= "	<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlSuspender .= "   <flgerlog>1</flgerlog>";
	$xmlSuspender .= " </Dados>";
	$xmlSuspender .= "</Root>";

	$xmlResult = mensageria($xmlSuspender, "APLI0008", "OBTEM_DADOS_SUSPENSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSuspender = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSuspender->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjSuspender->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}

	$poupanca = $xmlObjSuspender->roottag->tags[0]->tags[0]->tags;	
	$diadebit = $poupanca[7]->cdata;
	$dsfinali = $poupanca[28]->cdata ; // Finalidade

	// Flags para montagem do formulário
	$flgAlterar   = false;
	$flgSuspender = true;	
	$legend 	  = "Suspender";
	
	include("aplicacoes_programadas_formulario_dados.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
