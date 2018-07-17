<?php 

	/************************************************************************
	 Fonte: titulos_bordero_analisar.php                       
	 Autor: Lucas Lazari (GFT)                                                
	 Data : Abril/2008                �ltima Altera��o: 15/04/2018
	                                                                  
	 Objetivo  : Liberar um border� de desconto de t�tulos            
	                                                                  
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	$confirma = $_POST["confirma"];

	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"], 'L')) <> "") {
		exibeErro($msgError);		
	}	
	

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o indicador do tipo de impress�o � um inteiro v�lido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}

	// Carrega permiss�es do operador
	include("../../includes/carrega_permissoes.php");	
	
	//setVarSession("opcoesTela",$opcoesTela);
	
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";	
	$xml .= "		<confirma>".$confirma."</confirma>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	
	$xmlResult = mensageria($xml, 'TELA_ATENDA_DESCTO', 'LIBERAR_BORDERO',  $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getClassXML($xmlResult);
    $root = $xmlObj->roottag;

    
    // Se ocorrer um erro, mostra cr�tica
	if ($root->erro){
		exibeErro(htmlentities($root->erro->registro->dscritic));
		exit;
	} else if ($confirma == 0 && $root->dados->indrestr->cdata == 1) {
		echo 'showConfirmacao("'.htmlentities($root->dados->msgretorno->cdata).'","Confirma&ccedil;&atilde;o - Ayllos","liberarBorderoDscTit(1);","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit;
	} else {
		echo 'showError("inform","'.htmlentities($root->dados->msgretorno->cdata).'","Alerta - Ayllos","carregaBorderosTitulos();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit;
	}

	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 

		echo 'hideMsgAguardo();';
		//echo 'habilitaBotaoLiberar(\'N\');';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>