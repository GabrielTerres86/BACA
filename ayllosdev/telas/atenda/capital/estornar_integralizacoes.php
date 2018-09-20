<?php 
	//************************************************************************//
	//*** Fonte: estornar_integralizacoes.php                              
	//*** Autor: Fabricio                                                  
	//*** Data : Setembro/2013												Ultima Alteracao:            
	//***                                                                  
	//*** Objetivo  :		Estornar as integralizacoes de capital selecionadas. 
	//***                                                                  
	//*** Alteracoes:		Correcao na forma de recuperacao do retorno XML. SD 479874. Carlos R.
	//***
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlEstorno  = "";
	$xmlEstorno .= "<Root>";
	$xmlEstorno .= "	<Cabecalho>";
	$xmlEstorno .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlEstorno .= "		<Proc>estorna_integralizacao</Proc>";
	$xmlEstorno .= "	</Cabecalho>";
	$xmlEstorno .= "	<Dados>";
	$xmlEstorno .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlEstorno .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlEstorno .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlEstorno .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlEstorno .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlEstorno .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlEstorno .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlEstorno .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlEstorno .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Estorno', 'Itens');
	$xmlEstorno .= "	</Dados>";
	$xmlEstorno .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlEstorno);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjEstorno = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjEstorno->roottag->tags[0]->name) && strtoupper($xmlObjEstorno->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjEstorno->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	echo 'showError("inform","Estorno(s) realizado(s) com sucesso!","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	
	echo "acessaOpcaoAba(7,6,'L');";
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>