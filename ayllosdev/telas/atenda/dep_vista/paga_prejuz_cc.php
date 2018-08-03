<?php

/*!
 * FONTE        : pagamento_prejuizo.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 29/06/2018
 * OBJETIVO     : Realizar pagamento de prejuizo de conta corrente.
   ALTERAÇÕES   : 
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	isPostMethod();

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$vlrpagto = (isset($_POST['vlrpagto'])) ? str_replace(",",".",$_POST['vlrpagto']) : 0;
    $vlrabono = (isset($_POST['vlrabono'])) ? str_replace(",",".",$_POST['vlrabono']) : 0;

	if($vlrabono > 0){
		// pagamento de prejuízo de forma manual
		
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

	}else{
		// pagamento de prejuízo via liberação de saque		

		$xml2  = "<Root>";
		$xml2 .= " <Dados>";
		$xml2 .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml2 .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml2 .= "   <vlrlanc>".$vlrpagto ."</vlrlanc>";
		$xml2 .= " </Dados>";
		$xml2 .= "</Root>";

		$acao = "GERA_LCM";	

		$xmlResult = mensageria($xml2, "PREJ0003", $acao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);
	}	

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos',"",false);
	}else{
		exibirErro('inform','Pagamento de Prejuízo efetuado com sucesso!','Alerta - Ayllos',"",false);
	}	
	
	
	
?>
