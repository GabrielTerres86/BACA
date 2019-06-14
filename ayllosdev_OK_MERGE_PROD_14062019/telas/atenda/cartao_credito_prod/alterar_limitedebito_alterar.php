<?php 

	/************************************************************************************
		Fonte: alterar_limitedebito_alterar.php
		Autor: Guilherme
		Data : Abril/2008      
		&Uacute;ltima Altera&ccedil;&atilde;o: 11/04/2013

		Objetivo  : 	Efetuar altera&ccedil;&atilde;o de limite de d&eacute;bito do 
					    Cart&atilde;o de Cr&eacute;dito - rotina de Cart&atilde;o de 
						Cr&eacute;dito da tela ATENDA

		Alteracoes: 08/09/2011 - Incluido a chamada para a procedure alerta_fraude
								 (Adriano).
								 
					11/04/2013 - Retirado a chamada da procedure alerta_fraude (Adriano)
								 
	 *************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) ||
    !isset($_POST["nrctrcrd"]) ||
		!isset($_POST["vllimdeb"]) ||
			!isset($_POST["nrcpfcgc"]) ){
		exibeErro("Par&acirc;metros incorretos.");
	}

	
	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$vllimdeb = $_POST["vllimdeb"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se n&uacute;mero do contrato &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se valor do limite de d&eacute;bito &eacute; um decimal valido
	if (!validaDecimal($vllimdeb)) {
		exibeErro("Valor do limite de d&eacute;bito inv&aacute;lida.");
	}
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>altera_limdeb_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<vllimdeb>".$vllimdeb."</vllimdeb>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@" - Principal
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	echo 'hideMsgAguardo();';

	// Mostra se Bo retornar mensagem de atualiza&ccedil;&atilde;o de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	// Mostra a mensagem de informa&ccedil;&atilde;o para verificar atualiza&ccedil;&atilde;o cadastral se for adm BB
	if ($idconfir == 1) {
		echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","");';
	} else if ($idconfir == 2){
		exibeErro($dsmensag);
	}	
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado - Carrega o principal novamente.
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	} else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>