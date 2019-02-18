<?php

	//************************************************************************//
	//*** Fonte: consulta_icf.php                                          ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Marco/2013                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Exibir os dados obtidos na consulta dos              ***//	
	//***             processamentos do ICF.                               ***//
	//***                                                                  ***//
	//***                                                                  ***//
	//*** Alterações: 												       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C");
		
	$dtinireq = $_POST["dtinireq"];
	$intipreq = $_POST["intipreq"];
	$cdbanreq = $_POST["cdbanreq"];
	$cdagereq = $_POST["cdagereq"];
	$nrctareq = $_POST["nrctareq"];
	$dsdocmc7 = htmlspecialchars($_POST["dsdocmc7"]);
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "	<Cabecalho>";
	$xmlConsulta .= "		<Bo>b1wgen0154.p</Bo>";
	$xmlConsulta .= "		<Proc>consulta-icf</Proc>";
	$xmlConsulta .= "	</Cabecalho>";
	$xmlConsulta .= "	<Dados>";
	$xmlConsulta .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "		<dtinireq>".$dtinireq."</dtinireq>";
	$xmlConsulta .= "		<intipreq>".$intipreq."</intipreq>";
	$xmlConsulta .= "		<cdbanreq>".$cdbanreq."</cdbanreq>";
	$xmlConsulta .= "		<cdagereq>".$cdagereq."</cdagereq>";
	$xmlConsulta .= "		<nrctareq>".$nrctareq."</nrctareq>";
	$xmlConsulta .= "		<dsdocmc7>".$dsdocmc7."</dsdocmc7>";
	$xmlConsulta .= "	</Dados>";
	$xmlConsulta .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsulta = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		
	$dados = $xmlObjConsulta->roottag->tags[0]->tags;
	$dados_count = count($dados);
		
	include('form_tabela_consulta.php');
	
	
	
?>