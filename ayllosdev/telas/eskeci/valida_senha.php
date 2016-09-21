<?php

	/*************************************************************************
	  Fonte: valida_senha.php                                               
	  Autor: Henrique                                                  
	  Data : Junho/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Validar a nova senha.              
	                                                                 
	  Alterações: 										   			  
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$nrsennov = $_POST["nrsennov"];
    $nrsencon = $_POST["nrsencon"];

	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "   <Bo>b1wgen0098.p</Bo>";
	$xmlCarregaDados .= "   <Proc>verifica-nova-senha</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCarregaDados .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCarregaDados .= "	<nrdconta>".$nrdconta."</nrdconta>";
	$xmlCarregaDados .= "	<idseqttl>1</idseqttl>";
	$xmlCarregaDados .= "   <nrcartao>".$nrcartao."</nrcartao>";
	$xmlCarregaDados .= "	<nrsennov>".$nrsennov."</nrsennov>";
	$xmlCarregaDados .= "	<nrsencon>".$nrsencon."</nrsencon>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlObjCarregaDados = getObjectXML($xmlResult);
	
	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCarregaDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCarregaDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
    echo "showConfirmacao('Confirma a altera&ccedil;&atilde;o da senha?','Senha','gravaSenha();','estadoInicial();','sim.gif','nao.gif');";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>