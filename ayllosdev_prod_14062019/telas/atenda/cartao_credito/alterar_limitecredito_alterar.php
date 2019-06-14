<?php 

	/************************************************************************
	  Fonte: alterar_limitecredito_alterar.php
	  Autor: Guilherme
	  Data : Abril/2008                Última Alteração: 11/04/2013

	  Objetivo  : Efetua alteração do limite de crédito de Cartões de Crédito

	  Alterações: 05/11/2010 - Adaptação Cartão PJ (David).
	  
				  08/09/2011 - Incluido a chamada para a procedure alerta_fraude
							   (Adriano).
					
				  19/06/2012 - Adicionado confirmacao para impressao (Jorge)
					
				  11/04/2013 - Retirado a chamada da procedure alerta_fraude
							   (Adriano).
					
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	$params = array("nrdconta","nrctrcrd","vllimcrd","flgimpnp","nrcpfrep","inpessoa",
                    "nrctaav1","nmdaval1","nrcpfav1","tpdocav1","dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1","nrfonav1","emailav1",
                    "nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2","tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2",
                    "nrcpfcgc","redirect");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];
	$vllimcrd = $_POST["vllimcrd"];	
	$flgimpnp = $_POST["flgimpnp"];
	$nrcpfrep = $_POST["nrcpfrep"];
	
	$nrctaav1 = $_POST["nrctaav1"];
	$nmdaval1 = $_POST["nmdaval1"];
	$nrcpfav1 = $_POST["nrcpfav1"];
	$tpdocav1 = $_POST["tpdocav1"];
	$dsdocav1 = $_POST["dsdocav1"];
	$nmdcjav1 = $_POST["nmdcjav1"];
	$cpfcjav1 = $_POST["cpfcjav1"];
	$tdccjav1 = $_POST["tdccjav1"];
	$doccjav1 = $_POST["doccjav1"];
	$ende1av1 = $_POST["ende1av1"];
	$ende2av1 = $_POST["ende2av1"];
	$nrcepav1 = $_POST["nrcepav1"];
	$nmcidav1 = $_POST["nmcidav1"];
	$cdufava1 = $_POST["cdufava1"];
	$nrfonav1 = $_POST["nrfonav1"];	
	$emailav1 = $_POST["emailav1"];	
	$nrender1 = $_POST["nrender1"];
	$complen1 = $_POST["complen1"];
	$nrcxaps1 = $_POST["nrcxaps1"];

	$nrctaav2 = $_POST["nrctaav2"];
	$nmdaval2 = $_POST["nmdaval2"];
	$nrcpfav2 = $_POST["nrcpfav2"];
	$tpdocav2 = $_POST["tpdocav2"];
	$dsdocav2 = $_POST["dsdocav2"];
	$nmdcjav2 = $_POST["nmdcjav2"];
	$cpfcjav2 = $_POST["cpfcjav2"];
	$tdccjav2 = $_POST["tdccjav2"];
	$doccjav2 = $_POST["doccjav2"];
	$ende1av2 = $_POST["ende1av2"];
	$ende2av2 = $_POST["ende2av2"];
	$nrcepav2 = $_POST["nrcepav2"];
	$nmcidav2 = $_POST["nmcidav2"];
	$cdufava2 = $_POST["cdufava2"];
	$nrfonav2 = $_POST["nrfonav2"];
	$emailav2 = $_POST["emailav2"];
	$nrender2 = $_POST["nrender2"];
	$complen2 = $_POST["complen2"];
	$nrcxaps2 = $_POST["nrcxaps2"];
	$nrcpfcgc = $_POST["nrcpfcgc"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se valor do limite de crédito é um decimal válido
	if (!validaDecimal($vllimcrd)) {
		exibeErro("Valor do limite de cr&eacute;dito inv&aacute;lido.");
	}	
	
	// Valida impressão de nota promissória
	if ($flgimpnp <> "yes" && $flgimpnp <> "no") {
		exibeErro("Indicador de impress&atilde;o da nota promiss&oacute;ria inv&aacute;lido.");
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}

	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inv&aacute;lida.");
	}
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inv&aacute;lida.");
	}	
	
	// Verifica se CPF do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav1)) {
		exibeErro("CPF do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjugê do 1° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav1)) {
		exibeErro("CPF do C&ocirc;njuge do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) {
		exibeErro("CPF do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) {
		exibeErro("CPF do C&ocirc;njuge do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav1)) {
		exibeErro("CEP do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav2)) {
		exibeErro("CEP do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) {
		exibeErro("N&uacute;mero de CPF/CNPJ inv&aacute;lido.");
	}
	
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>altera_limcred_cartao</Proc>";
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
	$xmlSetCartao .= "		<vllimcrd>".$vllimcrd."</vllimcrd>";
	$xmlSetCartao .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlSetCartao .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";
	$xmlSetCartao .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlSetCartao .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlSetCartao .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlSetCartao .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlSetCartao .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlSetCartao .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlSetCartao .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlSetCartao .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlSetCartao .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlSetCartao .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlSetCartao .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlSetCartao .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlSetCartao .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlSetCartao .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlSetCartao .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlSetCartao .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlSetCartao .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlSetCartao .= "		<complen1>".$complen1."</complen1>";
	$xmlSetCartao .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";
	
	$xmlSetCartao .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlSetCartao .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlSetCartao .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlSetCartao .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlSetCartao .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlSetCartao .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlSetCartao .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlSetCartao .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlSetCartao .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlSetCartao .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlSetCartao .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlSetCartao .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlSetCartao .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlSetCartao .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlSetCartao .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlSetCartao .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlSetCartao .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlSetCartao .= "		<complen2>".$complen2."</complen2>";
	$xmlSetCartao .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";
	
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLimCredCrd = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimCredCrd->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimCredCrd->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$gerarimpr = 'gerarImpressao(2,'.($inpessoa == 1 ? 1 : 14).',0,'.$nrctrcrd.',0);';
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>