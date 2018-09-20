<?php 

	//************************************************************************//
	//*** Fonte: poupanca_resgate.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Acessar opção Resgate para Poupança Programada da    ***//
	//***             tela ATENDA                                          ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
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
	$xmlResgate  = "";
	$xmlResgate .= "<Root>";
	$xmlResgate .= "	<Cabecalho>";
	$xmlResgate .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlResgate .= "		<Proc>valida-resgate</Proc>";
	$xmlResgate .= "	</Cabecalho>";
	$xmlResgate .= "	<Dados>";
	$xmlResgate .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlResgate .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlResgate .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlResgate .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlResgate .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlResgate .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlResgate .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlResgate .= "		<idseqttl>1</idseqttl>";
	$xmlResgate .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlResgate .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlResgate .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlResgate .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlResgate .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlResgate .= "		<tpresgat></tpresgat>";
	$xmlResgate .= "		<vlresgat>0,00</vlresgat>";
	$xmlResgate .= "		<dtresgat></dtresgat>";
	$xmlResgate .= "		<flgoprgt>yes</flgoprgt>";
	$xmlResgate .= "	</Dados>";
	$xmlResgate .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlResgate);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjResgate = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjResgate->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjResgate->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	// Mostra div para opção de resgate
	echo '$("#divPoupancasPrincipal").css("display","none");';	
	echo '$("#divResgate").css("display","block");';	
	
	// Zerar variáveis globais utilizadas na opção resgate
	echo 'nrdocmto = 0;';
	echo 'flgoprgt = false;';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>