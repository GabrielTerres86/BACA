<?php 

	/*!
	 * FONTE        : habilitar_gravar.php
	 * AUTOR        : David
	 * DATA CRIAÇÃO : 01/11/2010 
	 * OBJETIVO     : Script para gravar dados da habilitação 
	 * 001: [29/10/2010] David: 		Desenvolver script habilitar_gravar.php
	 * 002: [19/06/2012] Jorge: 	    Adicionado confirmacao para impressao
	 * 003: [04/07/2014] Lucas Lunelli: Impressão comentada para Projeto Cartões Bancoob
	 */
	
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}
	
	$params = array("nrdconta","vllimglb","flgativo","nrcpfpri","nrcpfseg","nrcpfter","nmpespri","nmpesseg","nmpester","dtnaspri","dtnasseg","dtnaster",                    
                    "nrctaav1","nmdaval1","nrcpfav1","tpdocav1","dsdocav1","nmdcjav1","cpfcjav1","tdccjav1","doccjav1","ende1av1","ende2av1","nrcepav1","nmcidav1","cdufava1","nrfonav1","emailav1",
                    "nrctaav2","nmdaval2","nrcpfav2","tpdocav2","dsdocav2","nmdcjav2","cpfcjav2","tdccjav2","doccjav2","ende1av2","ende2av2","nrcepav2","nmcidav2","cdufava2","nrfonav2","emailav2");                    
	
	// Verifica se os parâmetros necessários foram informados
	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}
	
	$nrdconta = $_POST["nrdconta"];
	
	$vllimglb = $_POST["vllimglb"];
	$flgativo = $_POST["flgativo"];
	$nrcpfpri = $_POST["nrcpfpri"];
	$nrcpfseg = $_POST["nrcpfseg"];
	$nrcpfter = $_POST["nrcpfter"];
	$nmpespri = $_POST["nmpespri"];
	$nmpesseg = $_POST["nmpesseg"];
	$nmpester = $_POST["nmpester"];
	$dtnaspri = $_POST["dtnaspri"];
	$dtnasseg = $_POST["dtnasseg"];
	$dtnaster = $_POST["dtnaster"];
	
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

	// Verifica se némero da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se limite empresarial é um decimal válido
	if (!validaDecimal($vllimglb)) {
		exibeErro("Limite empresarial inv&aacute;lido.");
	}

	// Verifica se flag que indica se limite está ativo é válida
	if ($flgativo <> "yes" && $flgativo <> "no") {
		exibeErro("Indicador de situação do limite inv&aacute;lido.");
	}

	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfpri)) {
		exibeErro("CPF do primeiro representante inv&aacute;lido.");		
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfseg)) {
		exibeErro("CPF do segundo representante inv&aacute;lido.");		
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfter)) {
		exibeErro("CPF do terceiro representante inv&aacute;lido.");		
	}
	
	// Verifica se data de nascimento do representante é válida
	if ($dtnaspri <> "" && !validaData($dtnaspri)) {
		exibeErro("Data de nascimento do primeiro representante inv&aacute;lida.");		
	}
	
	// Verifica se data de nascimento do representante é válida
	if ($dtnasseg <> "" && !validaData($dtnasseg)) {
		exibeErro("Data de nascimento do segundo representante inv&aacute;lida.");		
	}
	
	// Verifica se data de nascimento do representante é válida
	if ($dtnaster <> "" && !validaData($dtnaster)) {
		exibeErro("Data de nascimento do terceiro representante inv&aacute;lida.");		
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
		exibeErro("CPF do Conjug&ecirc; do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) {
		exibeErro("CPF do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) {
		exibeErro("CPF do Conjug&ecirc; do 2o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcepav1)) {
		exibeErro("CEP do 1o Avalista inv&aacute;lido.");
	}	
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav2)) {
		exibeErro("CEP do 2o Avalista inv&aacute;lido.");
	}
	
	// Monta o xml de requisição
	$xmlHabilita  = "";
	$xmlHabilita .= "<Root>";
	$xmlHabilita .= "	<Cabecalho>";
	$xmlHabilita .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlHabilita .= "		<Proc>grava_dados_habilitacao</Proc>";
	$xmlHabilita .= "	</Cabecalho>";
	$xmlHabilita .= "	<Dados>";
	$xmlHabilita .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlHabilita .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlHabilita .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlHabilita .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlHabilita .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlHabilita .= "		<vllimglb>".$vllimglb."</vllimglb>";
	$xmlHabilita .= "		<flgativo>".$flgativo."</flgativo>";
	$xmlHabilita .= "		<nrcpfpri>".$nrcpfpri."</nrcpfpri>";
	$xmlHabilita .= "		<nrcpfseg>".$nrcpfseg."</nrcpfseg>";
	$xmlHabilita .= "		<nrcpfter>".$nrcpfter."</nrcpfter>";
	$xmlHabilita .= "		<nmpespri>".$nmpespri."</nmpespri>";
	$xmlHabilita .= "		<nmpesseg>".$nmpesseg."</nmpesseg>";
	$xmlHabilita .= "		<nmpester>".$nmpester."</nmpester>";
	$xmlHabilita .= "		<dtnaspri>".$dtnaspri."</dtnaspri>";
	$xmlHabilita .= "		<dtnasseg>".$dtnasseg."</dtnasseg>";
	$xmlHabilita .= "		<dtnaster>".$dtnaster."</dtnaster>";
	$xmlHabilita .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlHabilita .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlHabilita .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlHabilita .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlHabilita .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlHabilita .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlHabilita .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlHabilita .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlHabilita .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlHabilita .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlHabilita .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlHabilita .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlHabilita .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlHabilita .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlHabilita .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlHabilita .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlHabilita .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlHabilita .= "		<complen1>".$complen1."</complen1>";
	$xmlHabilita .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";
	
	$xmlHabilita .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlHabilita .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlHabilita .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlHabilita .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlHabilita .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlHabilita .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlHabilita .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlHabilita .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlHabilita .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlHabilita .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlHabilita .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlHabilita .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlHabilita .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlHabilita .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlHabilita .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlHabilita .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlHabilita .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlHabilita .= "		<complen2>".$complen2."</complen2>";
	$xmlHabilita .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";
	
	$xmlHabilita .= "	</Dados>";
	$xmlHabilita .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlHabilita);

	// Cria objeto para classe de tratamento de XML
	$xmlObjHabilita = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjHabilita->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjHabilita->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$nrctrcrd = $xmlObjHabilita->roottag->tags[0]->attributes["NRCTRCRD"];
	
	// Procura índice da opção "@" - Principal
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado 
	if (!($idPrincipal === false)) {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
	}	else {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';	
	
	echo "metOpcaoAba = \"".$acessaaba."\";";	
	echo 'callafterCartaoCredito = \'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","callafterCartaoCredito = metOpcaoAba;gerarImpressao(2,2,0,'.$nrctrcrd.',0);",metOpcaoAba,"sim.gif","nao.gif");\';';

	/************************************************************************
	  Impressão comentada para Projeto Cartões Bancoob - Lucas Lunelli - 04/07/2014
	*************************************************************************
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","gerarImpressao(2,3,0,'.$nrctrcrd.',0);",metOpcaoAba,"sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	*************************************************************************/
	
	echo $acessaaba;	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>