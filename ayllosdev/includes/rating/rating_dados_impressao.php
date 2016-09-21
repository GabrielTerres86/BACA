<?php 

	//************************************************************************//
	//*** Fonte: rating_dados_impressao.php                                ***//
	//*** Autor: David                                                     ***//
	//*** Data : Junho/2010                   �ltima Altera��o: 04/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar dados para impress�o do RATING                ***//
	//***                                                                  ***//	 
	//*** Altera��es: 22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//***																   ***//
	//***			  04/06/2012 - Adcionado confirmacao de impressao e    ***//
	//***						   chamada de abreJanelaImpressao() (Jorge).**//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../config.php");
	require_once("../funcoes.php");		
	require_once("../controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");			
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["tpctrato"]) || !isset($_POST["nrctrato"]) || !isset($_POST["iddivcri"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpctrato = $_POST["tpctrato"];
	$nrctrato = $_POST["nrctrato"];
	$iddivcri = $_POST["iddivcri"];
	
		// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o tipo de contrato � um inteiro v�lido
	if (!validaInteiro($tpctrato)) {
		exibeErro("Tipo de contrato inv&aacute;lido.");		
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrato)) {
		exibeErro("Contrato inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {		
		// Monta tabela com cr�ticas do rating
		include ("rating_tabela_criticas.php");		
	} else {
		// Vari�vel que indica se o rating foi efetivado - Utilizado na include rating_armazena_dados_impressao.php
		$flgEfetivacao = false;
		
		// Include para mostrar informa��es sobre o rating efetivado na confirma��o do limite
		include("rating_armazena_dados_impressao.php");
		
		//confirma��o para gerar impressao
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));abreJanelaImpressao();","hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));","sim.gif","nao.gif");';
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	

?>