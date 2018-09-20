<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha_solicitacao_efetuar.php                        ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                Última Alteração: 08/11/2010 ***//
	//***                                                                  ***//
	//*** Objetivo  : Efetuar solicitação de 2via de Senha da rotina de    ***//
	//***             Cartões de Crédito da tela ATENDA                    ***//
	//***                                                                  ***//	 
	//*** Alterações: 08/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***                                                                  ***//	 
	//***             03/07/2014 - Alteração para impedir impressão        ***//	 
	//***                          quando cartão BANCOOB. (Lucas Lunelli)  ***//	 
	//***                                                                  ***//	 
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
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrcrd"]) || !isset($_POST["inpessoa"]) || 
	    !isset($_POST["repsolic"]) || !isset($_POST["nrcpfrep"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$inpessoa = $_POST["inpessoa"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$repsolic = $_POST["repsolic"];
	$nrcpfrep = $_POST["nrcpfrep"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se número do contrato é um inteiro válido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrcpfrep)) {
		exibeErro("CPF do representante inv&aacute;lido.");
	}
	
	// Monta o xml de requisição
	$xmlSet2ViaSenha  = "";
	$xmlSet2ViaSenha .= "<Root>";
	$xmlSet2ViaSenha .= "	<Cabecalho>";
	$xmlSet2ViaSenha .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSet2ViaSenha .= "		<Proc>efetua_solicitacao2via_senha</Proc>";
	$xmlSet2ViaSenha .= "	</Cabecalho>";
	$xmlSet2ViaSenha .= "	<Dados>";
	$xmlSet2ViaSenha .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSet2ViaSenha .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSet2ViaSenha .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSet2ViaSenha .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSet2ViaSenha .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSet2ViaSenha .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSet2ViaSenha .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSet2ViaSenha .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSet2ViaSenha .= "		<idseqttl>1</idseqttl>";
	$xmlSet2ViaSenha .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSet2ViaSenha .= "		<repsolic>".$repsolic."</repsolic>";
	$xmlSet2ViaSenha .= "		<nrcpfrep>".$nrcpfrep."</nrcpfrep>";
	$xmlSet2ViaSenha .= "	</Dados>";
	$xmlSet2ViaSenha .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSet2ViaSenha);

	// Cria objeto para classe de tratamento de XML
	$xmlObj2ViaSenha = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj2ViaSenha->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObj2ViaSenha->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';	
	
	$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';	
	
	// BANCOOB
	if ($cdadmcrd >= 10 &&
		$cdadmcrd <= 80 ){
		echo $acessaaba;
	}
	
	if ($inpessoa == "2") {
		$gerarimpr = 'gerarImpressao(2,12,0,'.$nrctrcrd.',0);';
		
		echo "callafterCartaoCredito = \"".$acessaaba."\";";
		
		// Efetua a impressão do termo de solicitação de 2 via de senha
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","'.$gerarimpr.'","'.$acessaaba.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	}else{
		echo $acessaaba;
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
