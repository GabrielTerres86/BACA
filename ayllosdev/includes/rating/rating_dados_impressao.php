<?php 

	//************************************************************************//
	//*** Fonte: rating_dados_impressao.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   Última Alteração: 04/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar dados para impressão do RATING                ***//
	//***                                                                  ***//	 
	//*** Alterações: 22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//***																   ***//
	//***			  04/06/2012 - Adcionado confirmacao de impressao e    ***//
	//***						   chamada de abreJanelaImpressao() (Jorge).**//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../config.php");
	require_once("../funcoes.php");		
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");			
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpctrato"]) || !isset($_POST["nrctrato"]) || !isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpctrato = $_POST["tpctrato"];
	$nrctrato = $_POST["nrctrato"];
	$iddivcri = $_POST["iddivcri"];
	
		// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o tipo de contrato é um inteiro válido
	if (!validaInteiro($tpctrato)) {
		exibeErro("Tipo de contrato inv&aacute;lido.");		
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrato)) {
		exibeErro("Contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisição
	$xmlRating  = "";
	$xmlRating .= "<Root>";
	$xmlRating .= "  <Cabecalho>";
	$xmlRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlRating .= "    <Proc>gera_rating</Proc>";
	$xmlRating .= "  </Cabecalho>";
	$xmlRating .= "  <Dados>";
	$xmlRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRating .= "    <idseqttl>1</idseqttl>";
	$xmlRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRating .= "    <dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlRating .= "    <inproces>".$glbvars["inproces"]."</inproces>";
	$xmlRating .= "    <tpctrato>".$tpctrato."</tpctrato>";
	$xmlRating .= "    <nrctrato>".$nrctrato."</nrctrato>";
	$xmlRating .= "    <flgcriar>FALSE</flgcriar>";
	$xmlRating .= "  </Dados>";
	$xmlRating .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {		
		// Monta tabela com críticas do rating
		include ("rating_tabela_criticas.php");		
	} else {
		// Variável que indica se o rating foi efetivado - Utilizado na include rating_armazena_dados_impressao.php
		$flgEfetivacao = false;
		
		// Include para mostrar informações sobre o rating efetivado na confirmação do limite
		include("rating_armazena_dados_impressao.php");
		
		//confirmação para gerar impressao
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));abreJanelaImpressao();","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	

?>