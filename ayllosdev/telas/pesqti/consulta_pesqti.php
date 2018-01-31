<?php 

	/**************************************************************************
	 Fonte: consulta_pesqti.php                                          
	 Autor: Adriano                                                      
	 Data : Agosto/2011                Última Alteração: 17/06/2015      
	                                                                     
	 Objetivo  : Consultar titulos e faturas                             
	                                                                     
	 Alterações: 06/08/2012 - Listar Históricos, campo Vl.FOZ e          
	                          implementação da Opção A (Lucas).          
	                                                                     
		 		  27/03/2013 - Alterações para tratar Convenios 	      
	 						   SICREDI (Lucas).     				      
	                                                                     
	             15/08/2013 - Alteração da sigla PAC para PA (Carlos)    	
	                                                                     
	             12/06/2014 - Alteração para exibir detalhes de DARFs    
	                          arrecadadas na Rot. 41 (SD. 75897 Lunelli) 
	                                                                     
                 16/12/2014 - #203812 Para as faturas (Cecred e Sicredi) 
	                          no lugar da descrição do Banco Destino e o 
	                          nome do banco, apresentar: Convênio e Nome 
	                          do convênio (Carlos)       

				 17/06/2015 - Ajuste decorrente a melhoria no layout da tela
 							  (Adriano).
							  
				 11/01/2018 - Alterações referente ao PRJ406.
	                                                                  	  
	**************************************************************************/
	
?>

<?php	
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
		
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	$tpdpagto = $_POST["tpdpagto"];
	$cdagenci = $_POST["cdagenci"];
	$dtdpagto = $_POST["dtdpagto"];
	$vldpagto = $_POST["vldpagto"];	
	$cdempcon = $_POST["cdempcon"];	
	$cdsegmto = $_POST["cdsegmto"];	
	$cdhiscxa = $_POST["cdhiscxa"];	
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;	
  
  //PJ406
  $dtipagto = $_POST["dtipagto"];
  $dtfpagto = $_POST["dtfpagto"];
  $nrdconta = $_POST["nrdconta"];
  $nrautdoc = $_POST["nrautdoc"];
			
	//Verifica se será consultado titulos ou faturas	
	if ($tpdpagto == "yes") {
		$procedure = "consulta_titulos";		
	}else{
		$procedure = "consulta_faturas";	
	}
	
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "  <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0101.p</Bo>";
	$xmlConsulta .= "    <Proc>".$procedure."</Proc>";
	$xmlConsulta .= "  </Cabecalho>";
	$xmlConsulta .= "  <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "    <dtdpagto>".$dtdpagto."</dtdpagto>";
	$xmlConsulta .= "    <vldpagto>".$vldpagto."</vldpagto>";
	$xmlConsulta .= "    <cdagenci>".$cdagenci."</cdagenci>";
	$xmlConsulta .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlConsulta .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "    <flgpagin>yes</flgpagin>";
	$xmlConsulta .= "    <nrregist>".$nrregist."</nrregist>";
	$xmlConsulta .= "    <cdhistor>".$cdhiscxa."</cdhistor>";
	$xmlConsulta .= "    <cdempcon>".$cdempcon."</cdempcon>";
	$xmlConsulta .= "    <cdsegmto>".$cdsegmto."</cdsegmto>";
	$xmlConsulta .= "    <nriniseq>".$nriniseq."</nriniseq>";
  //PJ406
  $xmlConsulta .= "    <dtipagto>".$dtipagto."</dtipagto>";
  $xmlConsulta .= "    <dtfpagto>".$dtfpagto."</dtfpagto>";
  $xmlConsulta .= "    <nrdconta>".$nrdconta."</nrdconta>";
  $xmlConsulta .= "    <nrautdoc>".$nrautdoc."</nrautdoc>";
  
	$xmlConsulta .= "  </Dados>";
	$xmlConsulta .= "</Root>";		
				
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCon = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjCon->roottag->tags[0]->name) == "ERRO") {		
		exibirErro('error', $xmlObjCon->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','controlaLayout(\'2\');',false);
		
	} 	
			
	$registros = $xmlObjCon->roottag->tags[0]->tags;
	$qtregist =  $xmlObjCon->roottag->tags[0]->attributes["QTREGIST"];
	$vlrtotal = $xmlObjCon->roottag->tags[0]->attributes["VLRTOTAL"];
	
	if ($qtregist == 0) { 					
		exibirErro('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','controlaLayout(\'2\');');		
	
	} else {      
	
		include('tab_registros.php'); 	
		include('form_titulos.php'); 
		include('form_titulos_2.php'); 
		include('form_faturas.php');
		include('form_faturas_2.php');
				
	}	 

?>