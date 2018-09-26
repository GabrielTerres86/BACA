<?php 

	//************************************************************************//
	//*** Fonte: buscar_integralizacoes.php                                ***//
	//*** Autor: Fabricio                                                  ***//
	//*** Data : Setembro/2013                Ultima Alteracao:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar integralizacoes de capital realizadas no dia. ***//
	//***                                                                  ***//
	//***                                                                  ***//	 
	//*** Alteracoes:                                                      ***//
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

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlBusca  = "";
	$xmlBusca .= "<Root>";
	$xmlBusca .= "	<Cabecalho>";
	$xmlBusca .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlBusca .= "		<Proc>busca_integralizacoes</Proc>";
	$xmlBusca .= "	</Cabecalho>";
	$xmlBusca .= "	<Dados>";
	$xmlBusca .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBusca .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlBusca .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlBusca .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlBusca .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlBusca .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlBusca .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlBusca .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlBusca .= "	</Dados>";
	$xmlBusca .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlBusca);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBusca = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjBusca->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBusca->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$lancamentos = $xmlObjBusca->roottag->tags[0]->tags;
	$count = count($lancamentos);
	
	if ($count <= 0)
		exibeErro("Lan&ccedil;amento(s) n&atilde;o encontrado(s)!");
	else
		include('tabela_integralizacao.php');
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>