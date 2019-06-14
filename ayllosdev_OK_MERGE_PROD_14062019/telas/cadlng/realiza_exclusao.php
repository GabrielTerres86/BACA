<?php

	/*************************************************************************
	  Fonte: realiza_exclusao.php                                               
	  Autor: Adriano                                                  
	  Data : Outubro/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Realiza a exclusao na CADLNG.              
	                                                                 
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrcpfcgc"]) || !isset($_POST["nrsequen"]) || !isset($_POST["dsmotexc"]) ) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
		
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nrsequen = $_POST["nrsequen"];	
	$dsmotexc = $_POST["dsmotexc"];
	
		
	//Motivo
	if ( $dsmotexc == ''  ){ 
		exibirErro('error','O campo Motivo da Exclus&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'detmotex\',\'frmDetalhes\');',false);
	}
		
	$xmlInclusao  = "";
	$xmlInclusao .= "<Root>";
	$xmlInclusao .= " <Cabecalho>";
	$xmlInclusao .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlInclusao .= "    <Proc>excluir</Proc>";
	$xmlInclusao .= " </Cabecalho>";
	$xmlInclusao .= " <Dados>";
	$xmlInclusao .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlInclusao .= "    <nrsequen>".$nrsequen."</nrsequen>";
	$xmlInclusao .= "	 <cdopeexc>".$glbvars["cdoperad"]."</cdopeexc>";
	$xmlInclusao .= "    <dsmotexc>".$dsmotexc."</dsmotexc>";
	$xmlInclusao .= "	 <dtexclus>".$glbvars["dtmvtolt"]."</dtexclus>";
	$xmlInclusao .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlInclusao .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlInclusao .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlInclusao .= " </Dados>";
	$xmlInclusao .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlInclusao);
		
	$xmlObjInclusao = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjInclusao->roottag->tags[0]->name) == "ERRO") {
		$dsdoerro = $xmlObjInclusao->roottag->tags[0]->tags[0]->tags[4]->cdata;
		echo 'showError("error","'.$dsdoerro.'","Alerta - Ayllos","");';
				
	}    
	
	echo '$("#detmotex",frmDetalhes).removeClass("campoErro");';
	echo 'realizaConsulta(1,30);';
	echo 'voltaDiv();';
	
?>
