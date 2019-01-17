<?php 

	/************************************************************************
	 Fonte: verifica_impressao.php                          
	 Autor: Daniel Zimmermann                                                 
	 Data : Dezembro/2018                Última Alteração: 17/12/2018
	                                                                  
	 Objetivo  : Rotina para verificar se permite impressão de proposta				        				   
	                                                                  	 
	 Alterações: 
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	
	$idimpres = $_POST["idimpres"];
	$limorbor = $_POST["limorbor"];
	$flgemail = $_POST["flgemail"];
	$fnfinish = $_POST["fnfinish"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do bordero é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato; inv&aacute;lido.");
	}	
	
	// Verifica se o borderô deve ser utilizado no sistema novo ou no antigo
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " 	<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " 	<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","VERIFICA_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		$msgErro = htmlentities($root->erro->registro->dscritic);
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit;
	} else {
		echo 'gerarImpressao('.$idimpres.','.$limorbor.','.$flgemail.','.$fnfinish.')';
		exit;
	}

?>