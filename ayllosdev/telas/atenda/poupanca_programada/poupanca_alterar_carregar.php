<?php 

	//************************************************************************//
	//*** Fonte: poupanca_alterar_carregar.php                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção para alterar Poupança Programada       ***//	
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
		
	// Monta o xml de requisição
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "	<Cabecalho>";
	$xmlAlterar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlAlterar .= "		<Proc>obtem-dados-alteracao</Proc>";
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
	$xmlAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAlterar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlAlterar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlAlterar .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
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
	
	$poupanca = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags;	
	
	// Flags para montagem do formulário
	$flgAlterar   = true;
	$flgSuspender = false;	
	$legend 	  = "Alterar";
	include("poupanca_formulario_dados.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											