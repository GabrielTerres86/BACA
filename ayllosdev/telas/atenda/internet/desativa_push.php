<?php 

	//************************************************************************//
	//*** Fonte: desativa_push.php                                         ***//
	//*** Autor: Jean Michel                                               ***//
	//*** Data : Setembro/2017                   Última Alteração:         ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar listagem de dispositivos Mobile              ***//
	//***                                                                  ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//***                                                                  ***//	 
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["idmobile"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$idmobile = $_POST["idmobile"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idmobile)) {
		exibeErro("Dispositivo inv&aacute;lido. ID: " . $idmobile);
	}
		
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '<dispositivomobileid>' . $idmobile . '</dispositivomobileid>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	// Enviar XML de ida e receber String XML de resposta		pc_relatorio_custos_orcados_
	$xmlResult = mensageria($xml, 'TELA_ATENDA_INTERNET', 'DESATIVA_PUSH', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}else{
		echo 'showError("inform","Os alertas para este dispositivo foram desativados com sucesso.","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));desativarPush()");';
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>