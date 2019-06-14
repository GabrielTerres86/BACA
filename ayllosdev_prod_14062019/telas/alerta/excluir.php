<?php

	/*************************************************************************
	  Fonte: excluir.php                                               
	  Autor: Adriano                                                  
	  Data : Fevereiro/2013                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Realiza a exclusao na ALERTA.              
	                                                                 
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrcpfcgc"]) || 
	    !isset($_POST["nrregres"]) || 
		!isset($_POST["dsjusexc"]) ) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
		
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$nrregres = $_POST["nrregres"];	
	$dsjusexc = $_POST["dsjusexc"];
	
		
	//Motivo da exclusão
	if ( $dsjusexc == ''  ){ 
		exibirErro('error','O campo Motivo da Exclus&atilde;o n&atilde;o foi preenchido!','Alerta - Ayllos','focaCampoErro(\'dsjusexc\',\'frmExcluir\');',false);
	}
		
	$xmlExcluir  = "";
	$xmlExcluir .= "<Root>";
	$xmlExcluir .= " <Cabecalho>";
	$xmlExcluir .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlExcluir .= "    <Proc>excluir_cad_restritivo</Proc>";
	$xmlExcluir .= " </Cabecalho>";
	$xmlExcluir .= " <Dados>";
	$xmlExcluir .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluir .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlExcluir .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluir .= "	 <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlExcluir .= "	 <dtexclus>".$glbvars["dtmvtolt"]."</dtexclus>";
	$xmlExcluir .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluir .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlExcluir .= "    <nrregres>".$nrregres."</nrregres>";
	$xmlExcluir .= "    <dsjusexc>".$dsjusexc."</dsjusexc>";
	$xmlExcluir .= " </Dados>";
	$xmlExcluir .= "</Root>";
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluir);
		
	$xmlObjExcluir = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExcluir->roottag->tags[0]->name) == "ERRO") {
				
		$msgErro = $xmlObjExcluir->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjExcluir->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = "$('dsjusexc','#frmExcluir').removeClass('campoErro');unblockBackground(); focaCampoErro('#".$nmdcampo."','frmExcluir');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
				
	}    
		
	echo '$("#dsjusexc","#frmExcluir").removeClass("campoErro");';
	echo 'controlaOperacao($(\'#cddopcao\',\'#frmCabAlerta\').val(),1,30);';
	echo 'controlaLayout("V1");';
	
		
?>
