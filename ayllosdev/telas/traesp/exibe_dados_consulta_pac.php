<?php
	//************************************************************************//
	//*** Fonte: exibe_dados_consulta_pac.php                              ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Marco/2012               Última Alteração:                ***//
	//***                                                                  ***//
	//*** Objetivo  : Listar Transacoes que nao foram feitos documentos    ***//	
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
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P");
	
	$cdagenci = $_POST["cdagenci"];
	$nriniseq = $_POST["nriniseq"];
	$nrregist = $_POST["nrregist"];
	
		
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo "$('#divDadosConsultaPac').html('');";
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#cdagenci\',\'#divConsultaPac\').focus();");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlTransacoesPac  = "";
	$xmlTransacoesPac .= "<Root>";
	$xmlTransacoesPac .= "	<Cabecalho>";
	$xmlTransacoesPac .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlTransacoesPac .= "		<Proc>consulta-transacoes-sem-documento</Proc>";
	$xmlTransacoesPac .= "	</Cabecalho>";
	$xmlTransacoesPac .= "	<Dados>";
	$xmlTransacoesPac .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlTransacoesPac .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlTransacoesPac .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlTransacoesPac .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlTransacoesPac .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xmlTransacoesPac .= "		<nrregist>".$nrregist."</nrregist>";
	$xmlTransacoesPac .= "	</Dados>";
	$xmlTransacoesPac .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlTransacoesPac);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTransacoesPac = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTransacoesPac->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTransacoesPac->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		
	$dados = $xmlObjTransacoesPac->roottag->tags[0]->tags;
	$total_registros = $xmlObjTransacoesPac->roottag->tags[0]->attributes["NRTOTREG"];
	$dados_count = count($dados);
	
	$nmdadiv   = '"#divDadosConsultaPac"';
	$nmdivform = '"#divConsultaPac"';
	$aux_id    = 2;
		
	include('form_tabela.php');
	
?>