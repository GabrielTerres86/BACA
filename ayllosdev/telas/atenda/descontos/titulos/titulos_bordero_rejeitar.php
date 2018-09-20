<?php 

	/************************************************************************
	 Fonte: titulos_bordero_analisar.php                       
	 Autor: Lucas Lazari (GFT)                                                
	 Data : Abril/2008                Última Alteração: 15/04/2018
	                                                                  
	 Objetivo  : Liberar um borderô de desconto de títulos            
	                                                                  
							  
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

	// Carrega permissões do operador
	include("../../../../includes/carrega_permissoes.php");
	
	setVarSession("opcoesTela",$opcoesTela);

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	$confirma = $_POST["confirma"];


	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o indicador do tipo de impressão é um inteiro válido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}


	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	

	$xmlResult = mensageria($xml, 'TELA_ATENDA_DESCTO', 'REJEITAR_BORDERO_TITULO',  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	
	$xmlObj = getClassXML($xmlResult);

    $root = $xmlObj->roottag;

    // Se ocorrer um erro, mostra crítica
	if ($root->erro){

		exibeErro(htmlentities($root->erro->registro->dscritic));
		
		exit;

	} else if ($confirma == 0 && $root->dados->indrestr->cdata == 1) {

		echo 'showConfirmacao("'.htmlentities($root->dados->msgretorno->cdata).'","Confirma&ccedil;&atilde;o - Aimaro","rejeitarBorderoDscTit(1);","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit;

	} else {
		
		echo 'showError("inform","'.htmlentities($root->tags[0]->cdata).'","Alerta - Aimaro","carregaBorderosTitulos();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		
		exit;
	}

	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 

		echo 'hideMsgAguardo();';
		//echo 'habilitaBotaoLiberar(\'N\');';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>