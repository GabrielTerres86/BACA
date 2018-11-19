<?php

	/****************************************************************
	 Fonte: excluir_score.php                                            
	 Autor: Christian Grauppe - Envolti                                                  
	 Data : Novembro/2018                 Última Alteração: 

	 Objetivo  : Rotina que realiza a exclusão do score.

	 Alter.:  

	*****************************************************************/
	
	session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E")) <> "") {
		echo 'showError("error", "'.$msgError.'", "Alerta - Ayllos", "bloqueiaFundo(divRotina);fechaRotina(divRotina);");';
	}
	
	$cdmodelo = isset($_POST["cdmodelo"]) ? $_POST["cdmodelo"] : '';
	$dtbase   = isset($_POST["dtbase"]) ? $_POST["dtbase"] : '';

	if ( ($cdmodelo=="") || ($dtbase=="") ) {
		echo 'showError("error", "Par&acirc;metros incorretos", "Alerta - Ayllos", "bloqueiaFundo(divRotina);fechaRotina(divRotina);");';
	}

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdmodelo>" . $cdmodelo . "</cdmodelo>";
	$xml .= "   <dtbase>" . $dtbase . "</dtbase>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "SCORE", "EXCLUI_CARGA_SCORE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		echo 'hideMsgAguardo();';
		echo 'showError("error", "'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'", "Alerta - Ayllos", "bloqueiaFundo(divRotina);fechaRotina(divRotina);");';
	} else {
		echo 'montaTab("","");';
	}

?>