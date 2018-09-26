<?php 

	/*!
	 * FONTE        : habilitar_validar.php
	 * AUTOR        : David
	 * DATA CRIAÇÃO : 29/10/2010 
	 * OBJETIVO     : Script para validar dados da habilitação 
	 * 001: [29/10/2010] David: Desenvolver script habilitar_validar.php
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
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["vllimglb"]) || !isset($_POST["flgativo"]) || !isset($_POST["nrcpfpri"]) || !isset($_POST["nrcpfseg"]) || 
	    !isset($_POST["nrcpfter"]) || !isset($_POST["nmpespri"]) || !isset($_POST["nmpesseg"]) || !isset($_POST["nmpester"]) || 
	    !isset($_POST["dtnaspri"]) || !isset($_POST["dtnasseg"]) || !isset($_POST["dtnaster"]) || !isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
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
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta inv&aacute;lida.");
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
	
	// Monta o xml de requisição
	$xmlHabilita  = "";
	$xmlHabilita .= "<Root>";
	$xmlHabilita .= "	<Cabecalho>";
	$xmlHabilita .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlHabilita .= "		<Proc>valida_habilitacao</Proc>";
	$xmlHabilita .= "	</Cabecalho>";
	$xmlHabilita .= "	<Dados>";
	$xmlHabilita .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlHabilita .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
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
	
	// Mostra div para digitação dos avalistas
	echo '$("#divDadosHabilita").css("display","none");';
	echo '$("#divDadosAvalistas").css("display","block");';
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>