<?php 
	/**************************************************************************
	      Fonte: limites_alterar.php     	 	                           
	      Autor: Lucas                                                    
	      Data : Maio/2012                   Última Alteração: 04/10/2015  
	                                                                  
          Objetivo  : Executa alterações nos limites do coop.		       
                                                                  	 
	                                                                  	 
	Alterações: 23/04/2013 - Incluido novos campos referente ao cadastro de limites Vr Boleto (David Kruger).						    
	                  04/10/2015 - Reformulacao cadastral                                                 
                17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM) 
				26/07/2016 - Corrigi a forma de recuperacao do retorno de erro no XML. SD 479874 (Carlos R.)
                05/09/2017 - Alteração referente ao Projeto Assinatura conjunta (Proj 397)
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["vllimweb"]) || !isset($_POST["vllimtrf"]) || 
			!isset($_POST["vllimpgo"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$vllimweb = $_POST["vllimweb"];
	$vllimtrf = $_POST["vllimtrf"];
	$vllimpgo = $_POST["vllimpgo"];
	$vllimted = $_POST["vllimted"];
	$vllimvrb = $_POST["vllimvrb"]; 
	$executandoProdutos = $_POST['executandoProdutos'];
	$idastcjt = $_POST["idastcjt"];

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
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetLimites  = "";
	$xmlSetLimites .= "<Root>";
	$xmlSetLimites .= "	<Cabecalho>";
	$xmlSetLimites .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetLimites .= "		<Proc>alterar-limites-internet</Proc>";
	$xmlSetLimites .= "	</Cabecalho>";
	$xmlSetLimites .= "	<Dados>";
	$xmlSetLimites .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetLimites .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetLimites .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetLimites .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetLimites .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xmlSetLimites .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetLimites .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetLimites .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetLimites .= "		<vllimweb>".$vllimweb."</vllimweb>";
	$xmlSetLimites .= "		<vllimtrf>".$vllimtrf."</vllimtrf>";
	$xmlSetLimites .= "		<vllimpgo>".$vllimpgo."</vllimpgo>";
	$xmlSetLimites .= "		<vllimted>".$vllimted."</vllimted>";	
	$xmlSetLimites .= "		<vllimvrb>".$vllimvrb."</vllimvrb>";	
	$xmlSetLimites .= "	</Dados>";
	$xmlSetLimites .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetLimites);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimites = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjLimites->roottag->tags[0]->name) && strtoupper($xmlObjLimites->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimites->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} else {

		/*if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
			exibeErro($msgError);		
		}*/
		
		$strnomacao = 'CORRIGI_LIMITES_PREPOSTOS';

		// Montar o xml para requisicao
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "<Dados>";
		$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
		$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "    <idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "    <vllimtrf>".$vllimtrf."</vllimtrf>";
		$xml .= "    <vllimpgo>".$vllimpgo."</vllimpgo>";
		$xml .= "    <vllimted>".$vllimted."</vllimted>";
		$xml .= "    <vllimvrb>".$vllimvrb."</vllimvrb>";
		$xml .= "</Dados>";
		$xml .= "</Root>";

		$xmlNResult = mensageria($xml, "ATENDA", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
		
		$xml_geral = simplexml_load_string($xmlNResult);	
		
		//exibeErro($xml_geral->pralerta);
		foreach($xml_geral as $newxml){
		  if ($newxml->pralerta != "OK") {
		    exibeErro($newxml->pralerta);
		  }			

		}
		
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
	
?>