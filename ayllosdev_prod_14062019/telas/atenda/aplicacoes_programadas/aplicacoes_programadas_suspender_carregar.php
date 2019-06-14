<?php 

	//**************************************************************************************//
	//*** Fonte: aplicacoes_programadas_suspender_carregar.php                           ***//
	//*** Autor: David                                                                   ***//
	//*** Data : Mar�o/2010                   Ultima Alteracao: 27/07/2018               ***//
	//***                                                                                ***//
	//*** Objetivo  : Mostrar op��o para suspender Aplica��o Programada                  ***//	
	//***                                                                                ***//	 
	//*** Altera��es: 27/07/2018 - Deriva��o para Aplica��o Programada                   ***//
	//***                     	   (Proj. 411.2 - CIS Corporate)                         ***// 
	//**************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	

	/*	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjSuspender->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjSuspender->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}

	$poupanca = $xmlObjSuspender->roottag->tags[0]->tags[0]->tags;	
	$diadebit = $poupanca[7]->cdata;
	$dsfinali = $poupanca[28]->cdata ; // Finalidade

	// Flags para montagem do formul�rio
	$flgAlterar   = false;
	$flgSuspender = true;	
	$legend 	  = "Suspender";
	
	include("aplicacoes_programadas_formulario_dados.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
