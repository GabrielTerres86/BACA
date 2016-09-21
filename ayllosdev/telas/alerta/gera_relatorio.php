<?php

	/*************************************************************************
	  Fonte: gera_relatorio.php                                               
	  Autor: Adriano                                                  
	  Data : Março/2013                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Gera relatorio com as justificativas - TELA ALERTA
	                                                                 
	  Alterações: 15/09/2014 - Chamado 152916 (Jonata-RKAM)										   			  
	                                                                  
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'R')) <> '') {		
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrcpfcgc"]) || 
	    !isset($_POST["nmpessoa"]) ) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.','Alerta - Ayllos');</script><?php
		exit();
			
	}	
		
		
	$dsiduser = session_id();	
	$nrcpfcgc = $_POST["nrcpfcgc"];	
	$nmpessoa = $_POST["nmpessoa"];	
	$tprelato = $_POST["tprelato"];	
	$dtinicio = $_POST["dtinicio"];	
	$dtdfinal = $_POST["dtdfinal"];	
		
	$xmlRelatorio  = "";
	$xmlRelatorio .= "<Root>";
	$xmlRelatorio .= " <Cabecalho>";
	$xmlRelatorio .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlRelatorio .= "    <Proc>gera_relatorio</Proc>";
	$xmlRelatorio .= " </Cabecalho>";
	$xmlRelatorio .= " <Dados>";
	$xmlRelatorio .= "	<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRelatorio .= "	<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRelatorio .= "	<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRelatorio .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlRelatorio .= "	<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlRelatorio .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlRelatorio .= "  <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlRelatorio .= "  <nmpessoa>".$nmpessoa."</nmpessoa>";
	$xmlRelatorio .= "  <dsiduser>".$dsiduser."</dsiduser>";
	$xmlRelatorio .= "  <tprelato>".$tprelato."</tprelato>";
	$xmlRelatorio .= "  <dtinicio>".$dtinicio."</dtinicio>";
	$xmlRelatorio .= "  <dtdfinal>".$dtdfinal."</dtdfinal>";
	$xmlRelatorio .= " </Dados>";
	$xmlRelatorio .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRelatorio);
		
	$xmlObjRelatorio = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRelatorio->roottag->tags[0]->name) == "ERRO") {
						
		$msg = $xmlObjRelatorio->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
						
	}    
	
	$nmarqpdf = $xmlObjRelatorio->roottag->tags[0]->attributes["NMARQPDF"];
	$nmarqimp = $xmlObjRelatorio->roottag->tags[0]->attributes["NMARQIMP"];
	
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);	

		
?>
