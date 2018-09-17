<?php 

	//************************************************************************//
	//*** Fonte: limites_validar_prep.php    	                           ***//
	//*** Autor: Everton                                                   ***//
	//*** Data : Junho/2017                  Última Alteração: 18/06/2017  ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar alterações nos limites dos prepostos.	       ***//
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["nrcpfcgc"])|| !isset($_POST["vllimweb"]) || !isset($_POST["vllimtrf"]) || !isset($_POST["vllimpgo"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$vllimweb = $_POST["vllimweb"];
	$vllimtrf = $_POST["vllimtrf"];
	$vllimpgo = $_POST["vllimpgo"];
	$vllimted = $_POST["vllimted"];
	$vllimvrb = $_POST["vllimvrb"];
	$vllimflp = $_POST["vllimflp"];
    
	//exibeErro($_POST["nrcpfcgc"]);
	 
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	

	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("Numero CPF de titular inv&aacute;lida.");
	}	
	
	// Verifica se limite di&aacute;rio &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vllimweb)) {
		exibeErro("Valor do limite di&aacute;rio inv&aacute;lido.");
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

	// Verifica se limite TED e um decimal valido
	if (!validaDecimal($vllimvrb)) {
		exibeErro("Valor do limite de Boletos inv&aacute;lido.");
	}
	
	// Verifica se limite TED e um decimal valido
	if (!validaDecimal($vllimflp)) {
		exibeErro("Valor do limite da Folha de pagamento inv&aacute;lido.");
	}

		$strnomacao = 'VALIDA_LIMITES_PREPOSTOS';
	
		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "    <vllimtrf>".$vllimtrf."</vllimtrf>";
		$xml .= "    <vllimpgo>".$vllimpgo."</vllimpgo>";
		$xml .= "    <vllimted>".$vllimted."</vllimted>";
		$xml .= "    <vllimvrb>".$vllimvrb."</vllimvrb>";
		$xml .= "    <vllimflp>".$vllimflp."</vllimflp>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		//exibeErro($xml);
		$xmlResult = mensageria($xml, "ATENDA" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	

		$xml_geral = simplexml_load_string($xmlResult);	
	    
        //exibeErro($xml_geral->pr_alerta);
		 
		if ($xml_geral->pr_alerta != "OK") {
		  exibeErro($xml_geral->pr_alerta);
	    } 
		//exibeErro($xml_geral->pr_alerta);
	   // exibeErro(PRINT_R($xml_geral));
	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>

<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

// Confirma altera&ccedil;&atilde;o dos limites
confirmaAlteracaoLimites2();
</script>
