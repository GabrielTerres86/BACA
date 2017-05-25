<?php 
/***************************************************************************************
 * FONTE        : cheques_desbloqueia_bordero.php				�ltima altera��o: --/--/----
 * CRIA��O      : Lombardi
 * DATA CRIA��O : 06/09/2016
 * OBJETIVO     : Desbloquear a inclus�o de novos borderos de desconto de cheque.
 *
 * Altera��es   : 
 *
 *
 **************************************************************************************/

	session_start();
		
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../class/xmlfile.php');
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D")) <> "") {
		exibirErro('error',htmlentities($msgError),'Alerta - Ayllos',"blockBackground(parseInt($('#divUsoGenerico').css('z-index')))",false);
	}
	
	isPostMethod();		
	  
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;
	
    $xmlRenovaLimite  = "";
	$xmlRenovaLimite .= "<Root>";
	$xmlRenovaLimite .= "   <Dados>";
	$xmlRenovaLimite .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlRenovaLimite .= "	   <nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlRenovaLimite .= "   </Dados>";
	$xmlRenovaLimite .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlRenovaLimite, "TELA_ATENDA_DESCTO", "DESBLOQUEIA_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjRenovaLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjRenovaLimite->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjRenovaLimite->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"blockBackground(parseInt($('#divRotina').css('z-index')))",false);
	}
	
	echo "showError(\"inform\",\"Opera&ccedil;&atilde;o efetuada com sucesso!\",\"Alerta - Ayllos\",\"fechaRotina($('#divUsoGenerico'),divRotina);carregaCheques();\");";
	
?>