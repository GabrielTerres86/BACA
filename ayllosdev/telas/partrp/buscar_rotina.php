<?php
	/*********************************************************************
	 Fonte: buscar_rotina.php
	 Autor: Jean Calao - Mout´S
	 Data : Mai/2017                                                                Ultima Alteracao: 25/05/2017

	 Objetivo  : Tratar as requisicoes da tela PARTRP

	 Alteracoes:
	**********************************************************************/

	session_start();

	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();
	
	$dsvlrprm1 = $_POST["dsvlrprm1"];
	$dsvlrprm2 = $_POST["dsvlrprm2"];
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	// Verifica Permissao
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","C")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <dsvlrprm1>".$dsvlrprm1."</dsvlrprm1>";
	$xml .= "    <dsvlrprm2>".$dsvlrprm2."</dsvlrprm2>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
    
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PARTRP", "TRFPRJ_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);
     
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	// Retornar os valores
	
	echo 'Cdsvlrprm1.val("'.$xmlObjeto->roottag->tags[0]->cdata.'");';
	echo 'Cdsvlrprm2.val("'.$xmlObjeto->roottag->tags[1]->cdata.'");';
	echo 'Cdsvlrprm3.val("'.$xmlObjeto->roottag->tags[2]->cdata.'");';
	echo 'Cdsvlrprm4.val("'.$xmlObjeto->roottag->tags[3]->cdata.'");';
	echo 'Cdsvlrprm5.val("'.$xmlObjeto->roottag->tags[4]->cdata.'");';
	echo 'Cdsvlrprm6.val("'.$xmlObjeto->roottag->tags[5]->cdata.'");';
	echo 'Cdsvlrprm7.val("'.$xmlObjeto->roottag->tags[6]->cdata.'");';
	echo 'Cdsvlrprm8.val("'.$xmlObjeto->roottag->tags[7]->cdata.'");';
	echo 'Cdsvlrprm9.val("'.$xmlObjeto->roottag->tags[8]->cdata.'");';
	echo 'Cdsvlrprm10.val("'.$xmlObjeto->roottag->tags[9]->cdata.'");';
	echo 'Cdsvlrprm11.val("'.$xmlObjeto->roottag->tags[10]->cdata.'");';
	echo 'Cdsvlrprm12.val("'.$xmlObjeto->roottag->tags[11]->cdata.'");';
	echo 'Cdsvlrprm13.val("'.$xmlObjeto->roottag->tags[12]->cdata.'");';
	echo 'Cdsvlrprm14.val("'.$xmlObjeto->roottag->tags[13]->cdata.'");';
	echo 'Cdsvlrprm15.val("'.$xmlObjeto->roottag->tags[14]->cdata.'");';
	echo 'Cdsvlrprm16.val("'.$xmlObjeto->roottag->tags[15]->cdata.'");';
	echo 'Cdsvlrprm17.val("'.$xmlObjeto->roottag->tags[16]->cdata.'");';
	echo 'Cdsvlrprm18.val("'.$xmlObjeto->roottag->tags[17]->cdata.'");';
	echo 'Cdsvlrprm19.val("'.$xmlObjeto->roottag->tags[18]->cdata.'");';
	echo 'Cdsvlrprm20.val("'.$xmlObjeto->roottag->tags[19]->cdata.'");';
	echo 'Cdsvlrprm21.val("'.$xmlObjeto->roottag->tags[20]->cdata.'");';
	echo 'Cdsvlrprm22.val("'.$xmlObjeto->roottag->tags[21]->cdata.'");';
	echo 'Cdsvlrprm23.val("'.$xmlObjeto->roottag->tags[22]->cdata.'");';
	echo 'Cdsvlrprm24.val("'.$xmlObjeto->roottag->tags[23]->cdata.'");';
	echo 'Cdsvlrprm25.val("'.$xmlObjeto->roottag->tags[24]->cdata.'");';
	echo 'Cdsvlrprm1.focus();';
?>
