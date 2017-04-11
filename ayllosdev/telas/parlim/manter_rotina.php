<?php 
	/*********************************************************************
	 Fonte: manter_rotina.php                                                 
	 Autor: Lucas Ranghetti                                                  
	 Data : Fevereiro/2017                Última Alteração: 
	                                                                  
	 Objetivo  : Tratar as requisicoes da tela PARLIM                                 
	                                                                  
	 Alterações: 
	 
	**********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	$cddopcao = $_POST["cddopcao"]; 
	$qtdiacor = $_POST["qtdiacor"];
	$vlminchq = $_POST["vlminchq"];
	$vlminiof = $_POST["vlminiof"];
	$vlminadp = $_POST["vlminadp"];
	
	if($cddopcao != 'CA' ){	     
		 // Verifica Permissão
		if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao)) <> "") {
			exibirErro('error',$msgError,'Alerta - Ayllos','btVoltar()',false);			
		}	
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <qtdiacor>".$qtdiacor."</qtdiacor>";
	$xml .= "    <vlminchq>".$vlminchq."</vlminchq>";
	$xml .= "    <vlminiof>".$vlminiof."</vlminiof>";
	$xml .= "    <vlminadp>".$vlminadp."</vlminadp>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PARLIM", "TELA_PARLIM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','btVoltar();',false);
	} 
	
	if ($cddopcao == 'C' || $cddopcao == 'CA') {
		$qtdiacor  =  $xmlObjeto->roottag->tags[0]->tags[0]->cdata; 
		$vlminchq  =  $xmlObjeto->roottag->tags[0]->tags[1]->cdata; 
		$vlminiof  =  $xmlObjeto->roottag->tags[0]->tags[2]->cdata; 
		$vlminadp  =  $xmlObjeto->roottag->tags[0]->tags[3]->cdata; 
		
		echo "Cqtdiacor.val('".$qtdiacor."');";
		echo "Cvlminchq.val('".$vlminchq."');";
		echo "Cvlminiof.val('".$vlminiof."');";
		echo "Cvlminadp.val('".$vlminadp."');";
		
	}elseif($cddopcao == 'A'){
			exibirErro('inform','Registro alterado com sucesso!','Alerta - Ayllos','btVoltar();',false);
	}else{
		exibirErro('inform','Registro incluido com sucesso!','Alerta - Ayllos','btVoltar();',false);
	}
		
?>