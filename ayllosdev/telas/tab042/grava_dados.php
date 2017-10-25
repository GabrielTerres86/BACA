<?php

	/*************************************************************************
	  Fonte: valida_senha.php                                               
	  Autor: Henrique                                                  
	  Data : Junho/2011                       Última Alteração: 13/09/2017		   
	                                                                   
	  Objetivo  : Validar a nova senha.              
	                                                                 
	  Alterações: 05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
                               departamento como parametros e passar o o código (Renato Darosci)	
							   
				  13/09/2017 - Correcao na validacao de permissoes na tela. SD 750528 (Carlos Rafael Tanholi).							   	
	                                                                  
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],' ','A',false)) <> '') {		
		exibeErro($msgError);
	}	
	
	$dstextab = ( isset($_POST["dstextab"]) ) ? $_POST["dstextab"] : '';

	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "   <Bo>b1wgen0106.p</Bo>";
	$xmlCarregaDados .= "   <Proc>altera_tab042</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlCarregaDados .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlCarregaDados .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlCarregaDados .= "	<flgerlog>TRUE</flgerlog>";
	$xmlCarregaDados .= "	<dstextab>".$dstextab."</dstextab>";
	$xmlCarregaDados .= "   <cddepart>".$glbvars["cddepart"]."</cddepart>";
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
	} else {
    echo "showError('inform','Contas alteradas','Contas para Libera&ccedil;&atilde;o de Prazo - Ayllos','150'); estadoConsulta();";
	}
?>