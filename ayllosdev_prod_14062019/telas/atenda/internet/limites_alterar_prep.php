<?php 
	/**************************************************************************
	      Fonte: limites_alterar_prep.php     	 	                           
	      Autor: Everton                                                    
	      Data : Junho/2017                   Última Alteração: 18/06/2017  
	                                                                  
          Objetivo  : Executa alterações nos limites do preposto.		       
                                                                  	 
	                                                                  	 
	**************************************************************************/
	
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["vllimweb"]) || !isset($_POST["vllimtrf"]) || !isset($_POST["vllimpgo"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
    //exibeErro($_POST["nrcpfcgc"]);
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$vllimweb = $_POST["vllimweb"];
	$vllimtrf = $_POST["vllimtrf"];
	$vllimpgo = $_POST["vllimpgo"];
	$vllimted = $_POST["vllimted"];
	$vllimvrb = $_POST["vllimvrb"];
	$vllimflp = $_POST["vllimflp"];	
	$idastcjt = $_POST["idastcjt"];
	$executandoProdutos = $_POST['executandoProdutos'];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Verifica se limite di&aacute;rio para transfer&ecirc;ncia &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimtrf)) {
		exibeErro("Valor do limite di&aacute;rio para transfer&ecirc;ncia inv&aacute;lido.");
	}	
	
	// Verifica se limite di&aacute;rio para pagamento &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimpgo)) {
		exibeErro("Valor do limite di&aacute;rio para pagamento inv&aacute;lido.");
	}			
	
	// Verifica se limite TED e um decimal valido
	if (!validaDecimal($vllimted)) {
		exibeErro("Valor do limite TED inv&aacute;lido.");
	}
	
	// Verifica se limite Folha PGTO e um decimal valido
	if (!validaDecimal($vllimflp)) {
		exibeErro("Valor do limite da Folha de Pagamento inv&aacute;lido.");
	}	
	
		$strnomacao = 'ALTERA_LIMITES_PREPOSTOS';

		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <nrcpf>".$nrcpfcgc."</nrcpf>";
		$xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "    <vllimtrf>".$vllimtrf."</vllimtrf>";
		$xml .= "    <vllimpgo>".$vllimpgo."</vllimpgo>";
		$xml .= "    <vllimted>".$vllimted."</vllimted>";
		$xml .= "    <vllimvrb>".$vllimvrb."</vllimvrb>";
		$xml .= "    <vllimflp>".$vllimflp."</vllimflp>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ATENDA", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
		
		$xml_geral = simplexml_load_string($xmlResult);	
		
		//exibeErro($xmlResult);
		
		if ($xml_geral->pr_alerta != "OK") {
		  exibeErro($xml_geral->pr_alerta);
	    } 
		
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	if ($executandoProdutos == 'true' && $idastcjt == 0) {
		echo 'encerraRotina();';
	} else {
		echo 'carregaHabilitacao();';
	}
	
			
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	if ($xml_geral->pr_operador == "S") {
		  exibeErro("Limite de Operadores diminuido conforme limite de Prepostos.");
	    } 
	
?>