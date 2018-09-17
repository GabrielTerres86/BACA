<?php
	//************************************************************************//
	//*** Fonte: exibe_dados_controle_movimentacao.php                     ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Abril/2012               Última Alteração:                ***//
	//***                                                                  ***//
	//*** Objetivo  : Listar controle de movimentacao em especie           ***//
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
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I");
	
	$dtmvtolt = $_POST["dtmvtolt"];
	$cdagenci = $_POST["cdagenci"];
	$cdbccxlt = $_POST["cdbccxlt"];
	$nrdolote = $_POST["nrdolote"];
	$nrdocmto = $_POST["nrdocmto"];
	$nrdconta = $_POST["nrdconta"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#cdagenci\',\'#divReimprimeControle\').focus();");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlTransaControle  = "";
	$xmlTransaControle .= "<Root>";
	$xmlTransaControle .= "	<Cabecalho>";
	$xmlTransaControle .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlTransaControle .= "		<Proc>consulta-controle-movimentacao</Proc>";
	$xmlTransaControle .= "	</Cabecalho>";
	$xmlTransaControle .= "	<Dados>";
	$xmlTransaControle .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlTransaControle .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlTransaControle .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlTransaControle .= "		<dttransa>".$dtmvtolt."</dttransa>";
	$xmlTransaControle .= "		<cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlTransaControle .= "		<nrdolote>".$nrdolote."</nrdolote>";
	$xmlTransaControle .= "		<nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlTransaControle .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlTransaControle .= "	</Dados>";
	$xmlTransaControle .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlTransaControle);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTransaControle = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTransaControle->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTransaControle->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
		
	$dados = $xmlObjTransaControle->roottag->tags[0]->tags;
	$dados_count = count($dados);
	
	$nmdadiv   = '"#divDadosMovimentacao"';
	$nmdivform = '"#divReimprimeControle"';
		
	include('form_tabela.php');
	
?>