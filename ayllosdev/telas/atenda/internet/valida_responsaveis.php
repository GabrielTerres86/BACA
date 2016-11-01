<?php 

	/****************************************************************
	 Fonte: valida_responsaveis.php
	 Autor: Jean Michel
	 Data : Novembro/2015               Última Alteração: 26/11/2015
	                                                                 
	 Objetivo  : Validacao de responsaveis por assinatura conjunta
	                                                                  
	 Alteraçães: 
	 ****************************************************************/	
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	$dscpfcgc = !isset($_POST["dscpfcgc"]) ? 0 : $_POST["dscpfcgc"];
	$nrdconta = !isset($_POST["nrdconta"]) ? 0 : $_POST["nrdconta"];
		
	//Validacao de responsaveis por assinatura conjunta
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0058.p</Bo>";
	$xml .= "		<Proc>valida_responsaveis</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<dscpfcgc>".$dscpfcgc."</dscpfcgc>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";	                            
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}else{
		echo("showConfirmacao('Confirma atualiza&ccedil;&atilde;o dos respons&aacute;veis pela assinatura conjunta?','Confirma&ccedil;&atilde;o - Ayllos','salvarRepresentantes();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');");
	}

?>