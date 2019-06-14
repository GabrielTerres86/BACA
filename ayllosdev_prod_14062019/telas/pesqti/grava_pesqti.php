<?php 
	/***********************************************************************
	 Fonte: grava_pesqti.php                                          
	 Autor: Lucas L.                                                  
	 Data : Agosto/2012                Última Alteração: 17/06/2015
	                                                                  
	 Objetivo  : Gravar alterações nas faturas                        
	                                                                  
	 Alterações: 06/08/2012 - Listar Históricos, campo Vl.FOZ e       
	                          implementação da Opção A (Lucas).    

				 17/06/2015 - Ajuste decorrente a melhoria no layout da tela
 				   	          (Adriano).
							  
	*************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}	
	
	$cdagefat = $_POST["cdagenci"];
	$nrdocmto = $_POST["nrdocmto"];
	$nrdolote = $_POST["nrdolote"];	
	$cdbccxlt = $_POST["cdbccxlt"];	
	$dtdpagto = $_POST["dtdpagto"];	
	$dscodbar = $_POST["dscodbar"];	
	$insitfat = $_POST["insitfat"];
		
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "  <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0101.p</Bo>";
	$xmlConsulta .= "    <Proc>grava-dados-fatura</Proc>";
	$xmlConsulta .= "  </Cabecalho>";
	$xmlConsulta .= "  <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlConsulta .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsulta .= "    <cdagefat>".$cdagefat."</cdagefat>";
	$xmlConsulta .= "    <dtdpagto>".$dtdpagto."</dtdpagto>";
	$xmlConsulta .= "    <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xmlConsulta .= "    <nrdolote>".$nrdolote."</nrdolote>";
	$xmlConsulta .= "    <cdbccxlt>".$cdbccxlt."</cdbccxlt>";
	$xmlConsulta .= "    <dscodbar>".$dscodbar."</dscodbar>";
	$xmlConsulta .= "    <insitfat>".$insitfat."</insitfat>";
	$xmlConsulta .= "  </Dados>";
	$xmlConsulta .= "</Root>";		
				
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCon = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCon->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error', $xmlObjCon->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','obtemConsulta(1,50)',false);
		
	} 

	echo 'obtemConsulta(1,50);';	
	
?>
	
	