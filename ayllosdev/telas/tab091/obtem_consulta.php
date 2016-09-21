<?php

	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Adriano                                                  
	  Data : Agosto/2011                       Última Alteração: 18/02/2013 		   
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB091.              
	                                                                 
	  Alterações: 18/02/2013 - Ajustes referente ao projeto Cadastro
							   Restritivo (Adriano).
	                                                                  
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
	
	if( !isset($_POST["cddopcao"]) || !isset($_POST["cdcooper"]) ) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
		
	$cddopcao = $_POST["cddopcao"];
	$cdcooper = $_POST["cdcooper"];
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= " <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0111.p</Bo>";
	$xmlConsulta .= "    <Proc>consulta_tab</Proc>";
	$xmlConsulta .= " </Cabecalho>";
	$xmlConsulta .= " <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsulta .= "	 <cdcopalt>".$cdcooper."</cdcopalt>";
	$xmlConsulta .= "    <dsdepart>".$glbvars["dsdepart"]."</dsdepart>";
	$xmlConsulta .= " </Dados>";
	$xmlConsulta .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);
	
	$xmlObjConsulta = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") {
		
		$dsdoerro = $xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro("error",$dsdoerro,"Alerta - Ayllos","voltaDiv();estadoInicial();"); 
		
	}    
	
	$dados = $xmlObjConsulta->roottag->tags[0]->tags;
	$dstextab = $xmlObjConsulta->roottag->tags[0]->attributes["DSTEXTAB"];
	$dsdemail = explode(",", $dstextab);
	
	include('form_tab091.php');
	
?>

<script type="text/javascript">	

	formataFormulario();
		
	if ('<? echo $cddopcao ?>' == "C") {
	
	
		cTodos.desabilitaCampo();
		cCddopcao.desabilitaCampo();
		cCdcooper.desabilitaCampo();
		$('#divMsgAjuda').css('display','block');
		$('#btVoltar','#divMsgAjuda').show().focus();
		$('#btAlterar','#divMsgAjuda').hide();
		
		
	} else {
	
		cTodos.habilitaCampo();
		cDsemail1.focus();
		cCddopcao.desabilitaCampo();
		cCdcooper.desabilitaCampo();
		$('#divMsgAjuda').css('display','block');
		$('#btVoltar','#divMsgAjuda').show();
		$('#btAlterar','#divMsgAjuda').show();
	}
			
</script>

