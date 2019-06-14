<?php 

	//************************************************************************//
	//*** Fonte: atualizar_preposto.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Fevereiro/2009               &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Atualizar Preposto para Cart&atilde;o Magn&eacute;tico - Rotina de ***//
	//***             Magn&eacute;ticos da tela ATENDA                            ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
	//************************************************************************//
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPreposto  = "";
	$xmlSetPreposto .= "<Root>";
	$xmlSetPreposto .= "	<Cabecalho>";
	$xmlSetPreposto .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlSetPreposto .= "		<Proc>atualizar-preposto</Proc>";
	$xmlSetPreposto .= "	</Cabecalho>";
	$xmlSetPreposto .= "	<Dados>";
	$xmlSetPreposto .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPreposto .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPreposto .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetPreposto .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetPreposto .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetPreposto .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetPreposto .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPreposto .= "		<idseqttl>1</idseqttl>";
	$xmlSetPreposto .= "		<nrcpfppt>".$nrcpfppt."</nrcpfppt>";
	$xmlSetPreposto .= "	</Dados>";
	$xmlSetPreposto .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPreposto);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPreposto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPreposto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPreposto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
?>