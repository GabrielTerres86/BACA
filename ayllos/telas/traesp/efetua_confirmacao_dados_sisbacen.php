<?php

	//*********************************************************************          ***//
	//*** Fonte: efetua_confirmacao_dados_sisbacen.php                               ***//
	//*** Autor: Fabricio                                                            ***//
	//*** Data : Outubro/2013                 Ultima Alteracao:                      ***//
	//***                                                                            ***//
	//*** Objetivo  : Confirmar dados no Sisbacen.                                   ***//
	//***			  							     								 ***//
	//***             		                                                         ***//
	//*** Alteracoes: 												                 ***//
	//***                                        							         ***//
	//***                                        		                             ***//
	//***                                        					                 ***//
	//*********************************************************************          ***//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$cdcooper = $_POST["cdcooper"];
	$identifi = $_POST["identifi"];
	$infoCoaf = $_POST["infoCoaf"];
	$justific = $_POST["justific"];
	$camposPc = $_POST["camposPc"];
	$dadosPrc = $_POST["dadosPrc"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
	// Procura indíce da opção "F"
	$idPrincipal = array_search("F",$glbvars["opcoesTela"]);
	
	if ($idPrincipal == false) {
		$idPrincipal = 0;
	}
	
	// Monta o xml de requisição
	$xmlFechamento  = "";
	$xmlFechamento .= "<Root>";
	$xmlFechamento .= "	<Cabecalho>";
	$xmlFechamento .= "		<Bo>b1wgen0135.p</Bo>";
	$xmlFechamento .= "		<Proc>efetua-confirmacao-sisbacen</Proc>";
	$xmlFechamento .= "	</Cabecalho>";
	$xmlFechamento .= "	<Dados>";
	$xmlFechamento .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xmlFechamento .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlFechamento .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlFechamento .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlFechamento .= "		<identifi>".$identifi."</identifi>";
	$xmlFechamento .= "		<infocoaf>".$infoCoaf."</infocoaf>";
	$xmlFechamento .= "		<justific>".$justific."</justific>";
	$xmlFechamento .= retornaXmlFilhos( $camposPc, $dadosPrc, 'Fechamento', 'Itens');
	$xmlFechamento .= "	</Dados>";
	$xmlFechamento .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlFechamento);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFechamento = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjFechamento->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjFechamento->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
?>