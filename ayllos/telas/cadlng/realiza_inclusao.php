<?php

	/*************************************************************************
	  Fonte: realiza_inclusao.php                                               
	  Autor: Adriano                                                  
	  Data : Outubro/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Realiza a inclusao na CADLNG.              
	                                                                 
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
	if (!isset($_POST["nrcpfcgc"]) || !isset($_POST["nmpessoa"]) || !isset($_POST["cdcoosol"]) ||
	    !isset($_POST["nmpessol"]) || !isset($_POST["dscarsol"]) || !isset($_POST["dsmotinc"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
	
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nmpessoa = $_POST["nmpessoa"];	
	$cdcoosol = $_POST["cdcoosol"];
	$nmpessol = $_POST["nmpessol"];
	$dscarsol = $_POST["dscarsol"];
	$cdopeinc = $_POST["cdopeinc"];
	$dsmotinc = $_POST["dsmotinc"];
	
		
	//CPF/CNPJ
	if ( $nrcpfcgc == ''  ){ 
		exibirErro('error','O campo CPF/CNPJ n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmIncCadlng\');',false);
	}
		
	//Nome
	if ( $nmpessoa == ''  ){
		exibirErro('error','O campo Nome n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'nmpessoa\',\'frmIncCadlng\');',false);
	}
	//Cooperativa Solicitante
	if ( $cdcoosol == ''  ){
		exibirErro('error','O campo Cooperativa Solicitante n&atilde;o foi informado!','Alerta - Ayllos','focaCampoErro(\'cdcoosol\',\'frmIncCadlng\');',false);
	}		
	//Pessoa Solicitante
	if ( $nmpessol == ''  ){
		exibirErro('error','O campo Nome Solicitante n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'nmpessol\',\'frmIncCadlng\');',false);
	}		
	//Descricao do cargo
	if ( $dscarsol == ''  ){
		exibirErro('error','O campo Cargo do Solicitante n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'dscarsol\',\'frmIncCadlng\');',false);
	}
	//Motivo
	if ( $dsmotinc == ''  ){ 
		exibirErro('error','O campo Motivo da Inclus&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'dsmotinc\',\'frmIncCadlng\');',false);
	}
		
		
	$xmlInclusao  = "";
	$xmlInclusao .= "<Root>";
	$xmlInclusao .= " <Cabecalho>";
	$xmlInclusao .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlInclusao .= "    <Proc>incluir</Proc>";
	$xmlInclusao .= " </Cabecalho>";
	$xmlInclusao .= " <Dados>";
	$xmlInclusao .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlInclusao .= "    <nmpessoa>".$nmpessoa."</nmpessoa>";
	$xmlInclusao .= "    <cdcoosol>".$cdcoosol."</cdcoosol>";
	$xmlInclusao .= "	 <nmpessol>".$nmpessol."</nmpessol>";
	$xmlInclusao .= "	 <dscarsol>".$dscarsol."</dscarsol>";
	$xmlInclusao .= "	 <cdopeinc>".$glbvars["cdoperad"]."</cdopeinc>";
	$xmlInclusao .= "	 <dtinclus>".$glbvars["dtmvtolt"]."</dtinclus>";
	$xmlInclusao .= "	 <dsmotinc>".$dsmotinc."</dsmotinc>";
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
	
	$msgRetorno = $xmlObjInclusao->roottag->tags[0]->attributes['MSGRETOR'];	
	
	if($msgRetorno != 0){
		if($msgRetorno == 1) {
			echo 'showError("inform","O CPF/CNPJ j&aacute; est&aacute; cadastrado.","Alerta - Ayllos","limpaCampos()");';
		}else{if($msgRetorno == 2){
				echo 'showError("inform","O CPF/CNPJ j&aacute; esteve cadastrado.","Alerta - Ayllos","limpaCampos()");';
			}
		}
	}else{
		echo 'limpaCampos();';
		echo '$("#dsmotinc",frmIncCadlng).removeClass("campoErro");';
		
		
	}
		
	
	
				 
?>
