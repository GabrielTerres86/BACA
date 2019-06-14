<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Adriano                                                  
	  Data : Agosto/2011                       �ltima Altera��o: 18/02/2013 		   
	                                                                   
	  Objetivo  : Grava parametros na craptab.             
	                                                                 
	  Altera��es: 18/02/2013 - Ajuste na mensagem de alerta referente ao 
							   projeto Cadastro Restritivo (Adriano).
						
	                                                                  
	***********************************************************************/

	session_start();
	
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	$dstextab = $_POST["dstextab"];
	$cdcopalt = $_POST["cdcooper"];
	
	$xmlGrava  = "";
	$xmlGrava .= "<Root>";
	$xmlGrava .= " <Cabecalho>";
	$xmlGrava .= "   <Bo>b1wgen0111.p</Bo>";
	$xmlGrava .= "   <Proc>altera_tab</Proc>";
	$xmlGrava .= " </Cabecalho>";
	$xmlGrava .= " <Dados>";
	$xmlGrava .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGrava .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGrava .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGrava .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGrava .= "	<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGrava .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGrava .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlGrava .= "	<flgerlog>TRUE</flgerlog>";
	$xmlGrava .= "	<dstextab>".$dstextab."</dstextab>";
	$xmlGrava .= "   <cdcopalt>".$cdcopalt."</cdcopalt>";
	$xmlGrava .= "   <dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xmlGrava .= " </Dados>";
	$xmlGrava .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGrava);
	
	$xmlObjGrava = getObjectXML($xmlResult);
	
	echo 'hideMsgAguardo();';
		
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjGrava->roottag->tags[0]->name) == "ERRO") {
		
		exibeErro($xmlObjGrava->roottag->tags[0]->tags[0]->tags[4]->cdata);
		
	} 
	
    echo "showError('inform','E-mail\'s alterados.','E-mail\'s para Envio do Cadastro Restritivo - Ayllos','voltaDiv();estadoInicial();');";
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","voltaDiv();estadoInicial();");';
		exit();
	}
	
?>