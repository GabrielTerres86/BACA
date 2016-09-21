<?php
	//************************************************************************//
	//*** Fonte: exibe_dados_consulta.php                                  ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Fevereiro/2012               Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Exibir os dados obtidos nas consultas                ***//	
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
	
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D");
		
		
	$nrdconta = $_POST["nrdconta"];
	$dtmvtolt = $_POST["dtmvtolt"];
	$nriniseq = $_POST["nriniseq"];
	$nrregist = $_POST["nrregist"];
		
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo "$('#divDadosConsulta').html('');";
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#nrdconta\',\'#divConsulta\').focus();");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlTransacoes  = "";
	$xmlTransacoes .= "<Root>";
	$xmlTransacoes .= "	<Cabecalho>";
	$xmlTransacoes .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlTransacoes .= "		<Proc>consulta-transacoes-especie</Proc>";
	$xmlTransacoes .= "	</Cabecalho>";
	$xmlTransacoes .= "	<Dados>";
	$xmlTransacoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlTransacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlTransacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlTransacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlTransacoes .= "		<dttransa>".$dtmvtolt."</dttransa>";
	$xmlTransacoes .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xmlTransacoes .= "		<nrregist>".$nrregist."</nrregist>";
	$xmlTransacoes .= "	</Dados>";
	$xmlTransacoes .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlTransacoes);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTransacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTransacoes->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTransacoes->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		
	$dados = $xmlObjTransacoes->roottag->tags[0]->tags;
	$total_registros = $xmlObjTransacoes->roottag->tags[0]->attributes["NRTOTREG"];
	$dados_count = count($dados);
	
	$nmdadiv   = '"#divDadosConsulta"';
	$nmdivform = '"#divConsulta"';
	$aux_id    = 1;
		
	include('form_tabela.php');
	
?>