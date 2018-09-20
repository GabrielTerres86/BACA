<?php 

	//************************************************************************//
	//*** Fonte: limites_preposto.php 	    	                           ***//
	//*** Autor: Everton                                                   ***//
	//*** Data : Junho/2017                   Última Alteração: 19/06/2017 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar tela para atualização de limites prepostos   ***//
	//***                                                                  ***//	 
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcpfcgc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	//exibeErro($nrcpfcgc);
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
		$strnomacao = 'ALTERA_PREPOSTOS_MASTER';
	
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "<Dados>";
		$xml .= "<cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "<nrcpf>".$nrcpfcgc."</nrcpf>";
		$xml .= "</Dados>";
		$xml .= "</Root>";
		
	    $xmlResult = mensageria($xml, "ATENDA" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	

		$xml_geral = simplexml_load_string($xmlResult);
		
		$xmlObjeto = getObjectXML($xmlResult);
		
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}		
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>