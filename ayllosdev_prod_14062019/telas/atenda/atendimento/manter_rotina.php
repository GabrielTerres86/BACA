<?php 

	/********************************************************************
	 Fonte: manter_rotina.php                                             
	 Autor: Gabriel - Rkam                                                     
	 Data : Agosto - 2015                  Última Alteração: 
	                                                                  
	 Objetivo  : Responsável por efetuar as rotinas de exclusão, inclusão
			     e alteração de um atendimento.
	                                                                  	 
	 Alteraçães: 
	 
	 
	*********************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
		
	}	
	
	// Verifica se os parâmetros foram enviados
	if (!isset($_POST["nrdconta"])             ||
	    !isset($_POST["dtatendimento"])        ||
		!isset($_POST["hratendimento"])        ||
		!isset($_POST["cdservico"])            ||
		!isset($_POST["dsservico_solicitado"]) ) {		
		exibirErro('error',"Par&acirc;metros incorretos.",'Alerta - Aimaro',"$('input,textarea','#frmServicos').removeClass('campoErro');$('#btVoltar','#divBotoesServicos').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))",false);
	}	

	$nrdconta      = $_POST["nrdconta"];
	$dtatendimento = $_POST["dtatendimento"];
	$hratendimento = $_POST["hratendimento"];
	$cdservico     = $_POST["cdservico"];
	$dsservico_solicitado = $_POST["dsservico_solicitado"];

	validaDados();	
	
	// Monta o xml de requisição
	$xmlExcluiServicosOferecidos  = "";
	$xmlExcluiServicosOferecidos .= "<Root>";
	$xmlExcluiServicosOferecidos .= "   <Dados>";
	$xmlExcluiServicosOferecidos .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlExcluiServicosOferecidos .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluiServicosOferecidos .= "	   <dtatendimento>".$dtatendimento."</dtatendimento>";
	$xmlExcluiServicosOferecidos .= "	   <hratendimento>".$hratendimento."</hratendimento>";	
	$xmlExcluiServicosOferecidos .= "	   <cdservico>".$cdservico."</cdservico>";	
	$xmlExcluiServicosOferecidos .= "	   <dsservico>".$dsservico_solicitado."</dsservico>";
	$xmlExcluiServicosOferecidos .= "   </Dados>";
	$xmlExcluiServicosOferecidos .= "</Root>";
								
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlExcluiServicosOferecidos, "ATENDIMENTO", "REGISTROSERVICOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjServicos = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjServicos->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro  = $xmlObjServicos->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjServicos->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if ( !empty($nmdcampo) ) { 
			if($cddopcao == 'E' || ($cddopcao == 'A' && ($nmdcampo == 'dtatendimento' || $nmdcampo == 'hratendimento') ) ){
				$mtdErro = "$('input,textarea','#frmServicos').removeClass('campoErro');$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))";  
			}else{
				$mtdErro = "$('input,textarea','#frmServicos').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmServicos');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))";  
			}
		}else{
			$mtdErro = "$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))";  
		}
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
						
	}
		
	echo 'buscaRegistro(1,30);';
		
	
	function validaDados(){
		
		//Conta
		if ( $GLOBALS["nrdconta"] == 0 || !validaInteiro($GLOBALS["nrdconta"])){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
		if($GLOBALS["cddopcao"] == 'I'){
			
			//Data atendimento
			if ( $GLOBALS["dtatendimento"] == ''){ 
				exibirErro('error','Data de atendimento inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'dtatendimento\',\'frmServicos\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
			
			//Hora atendimento
			if ( $GLOBALS["hratendimento"] == '' ){ 
				
				exibirErro('error','Hora de atendimento inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'hratendimento\',\'frmServicos\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
		}else{
			
			//Data atendimento
			if ( $GLOBALS["dtatendimento"] == ''){ 
				exibirErro('error','Data de atendimento inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
			
			//Hora atendimento
			if ( $GLOBALS["hratendimento"] == '' ){ 
				
				exibirErro('error','Hora de atendimento inv&aacute;lida.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesServicos\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			}
		}
		
		//Código do serviço
		if ( $GLOBALS["cddopcao"] != 'E' && $GLOBALS["cdservico"] == 0){ 
			exibirErro('error','C&oacute;digo do servi&ccedil;o inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'cdservico\',\'frmServicos\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		}
		
	}
?>
