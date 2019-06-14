<?php 

	//************************************************************************//
	//*** Fonte: 2via_entrega_efetuar.php                                  ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Março/2008                   Última Alteração: 19/06/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Efetuar a entrega da segunda via do cartão de        ***//
	//***             crédito                                              ***//
	//***                                                                  ***//	 
	//*** Alterações: 04/09/2008 - Adaptação para solicitação de 2 via de  ***//
	//***                          senha de cartão de crédito (David)      ***//	
	//***                                                                  ***//	 	
	//***             14/05/2009 - Tirar validação de data para parâmetro  ***//
	//***                          "dtvalida" (David).                     ***//
	//***                                                                  ***//
	//***             08/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***																   ***//
	//***			  19/06/2012 - Adicionado confirmacao para impressao   ***//
	//***						   (Jorge)								   ***//
	//************************************************************************//		 
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se os parâmetros necessários foram informados
	$params = array("nrdconta","nrctrcrd","nrcrcard","dtvalida","cdadmcrd","flgimpnp","nrcpfrep","repsolic","inpessoa",
                    "nrctaav1","nmdaval1","nrcpfav1","tpdocav1","dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1","nrfonav1","emailav1",
                    "nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2","tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2",
                    "redirect");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}

	$nrdconta = $_POST["nrdconta"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$nrcrcard = $_POST["nrcrcard"];
	$dtvalida = $_POST["dtvalida"];
	$flgimpnp = $_POST["flgimpnp"];
	$inpessoa = $_POST["inpessoa"];
	$repsolic = $_POST["repsolic"];
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

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se número do cartão é um inteiro válido
	if (!validaInteiro($nrcrcard)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}		
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}		
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se o código da adm é um inteiro válido
	if (!validaInteiro($cdadmcrd)) {
		exibeErro("C&oacute;digo da Administradora inv&aacute;lido.");
	}
	
	// Verifica se a nova data de validade é um inteiro válido
	if (!validaInteiro($dtvalida)) {
		exibeErro("Data de validade inv&aacute;lida.");
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
	
	// Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>efetua_entrega2via_cartao</Proc>";
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
	$xmlSetCartao .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard>".$nrcrcard."</nrcrcard>";
	$xmlSetCartao .= "		<dtvalida>".$dtvalida."</dtvalida>";
	$xmlSetCartao .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlSetCartao .= "		<repsolic>".$repsolic."</repsolic>";
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
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$nrctr2vi = $xmlObjCartao->roottag->tags[0]->attributes["NRCTR2VI"];	
		
	if ($cdadmcrd == 1) { /* Credicard */
		$idimpres = 5; 
	} elseif ($cdadmcrd == 2) { /* BRADESCO/VISA */
		$idimpres = 2; 
	} elseif ($cdadmcrd == 3) { /* CECRED/VISA */ 
		$idimpres = $inpessoa == 1 ? 2 : 9; 
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$gerarimpr = 'gerarImpressao(2,'.$idimpres.',\''.$cdadmcrd.'\','.$nrctr2vi.',0);';		
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	
	echo "callafterCartaoCredito = \"".$acessaaba."\";";
	
	// Efetua a impressão do termo de entrega
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
