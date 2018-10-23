<?php

/*!
 * FONTE        : pagamento_prejuizo.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 29/06/2018
 * OBJETIVO     : Realizar pagamento de prejuizo de conta corrente.
 * ALTERAÇÕES   : 
 *
 *			      04/09/2018 - Ajuste na mensagem de pagamento de prejuizo em conta sem saldo
 *        	   		           PJ450 - Diego Simas - AMcom 
 *
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	isPostMethod();

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$vlrpagto = (isset($_POST['vlrpagto'])) ? str_replace(",",".", str_replace(".", "", $_POST['vlrpagto'])) : 0;
    $vlrabono = (isset($_POST['vlrabono'])) ? str_replace(",",".", str_replace(".", "", $_POST['vlrabono'])) : 0;

		
	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml2 .= "   <vlrpagto>".$vlrpagto."</vlrpagto>";
	$xml2 .= "   <vlrabono>".$vlrabono."</vlrabono>";
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$acao = "PAGA_PREJUIZO_CC";

	$xmlResult = mensageria($xml2, "TELA_ATENDA_DEPOSVIS", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);		

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"",false);
	}else{
		exibirErro('inform',utf8ToHtml('Pagamento de Prejuízo efetuado com sucesso!'),'Alerta - Ayllos',"mostraDetalhesCT()",false);
	}		
?>
