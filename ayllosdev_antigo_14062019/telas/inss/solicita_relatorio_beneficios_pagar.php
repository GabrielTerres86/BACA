<?php

	/***********************************************************************************
	  Fonte: solicita_relatorio_beneficios_pagar.php                                               
	  Autor: Adriano                                                  
	  Data : Junho/2013                     		  Última Alteração: 20/10/2015
	                                                                   
	  Objetivo  : Solicita relatorio de beneficios a pagar e bloqueados
	                                                                 
	  Alterações: 10/03/2015 - Ajuste referente ao Histórico cadastral
						      (Adriano - Softdesk 261226).											   			  
	                                                                  
                20/10/2015 - Adicionados campos data inicio e data fim no filtro 
                             do relatorio - Projeto 255 (Lombardi).
	                                                                  
	************************************************************************************/

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
		
	
	$cdagesel = (isset($_POST["cdagesel"])) ? $_POST["cdagesel"] : '';
	$nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : 0;
    $dtinirec = (isset($_POST["dtinirec"])) ? $_POST["dtinirec"] : '';
    $dtfinrec = (isset($_POST["dtfinrec"])) ? $_POST["dtfinrec"] : '';

	$dsiduser = session_id();			
	
	$xmlSolicitaRelatorioBeneficiosPagar  = "";
	$xmlSolicitaRelatorioBeneficiosPagar .= "<Root>";
	$xmlSolicitaRelatorioBeneficiosPagar .= " <Dados>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "	 <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    <cdagesel>".$cdagesel."</cdagesel>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    <nrrecben>".$nrrecben."</nrrecben>";
    $xmlSolicitaRelatorioBeneficiosPagar .= "    <dtinirec>".$dtinirec."</dtinirec>";
    $xmlSolicitaRelatorioBeneficiosPagar .= "    <dtfinrec>".$dtfinrec."</dtfinrec>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "    <tpnrbene>NB</tpnrbene>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "     <tpconrel>NAO_PAGOS</tpconrel>";	
	$xmlSolicitaRelatorioBeneficiosPagar .= "     <idtiprel>PAGAR</idtiprel>";	
	$xmlSolicitaRelatorioBeneficiosPagar .= "     <dsiduser>".$dsiduser."</dsiduser>";	
	$xmlSolicitaRelatorioBeneficiosPagar .= " </Dados>";
	$xmlSolicitaRelatorioBeneficiosPagar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlSolicitaRelatorioBeneficiosPagar, "INSS", "RELPAGOSPAGARINSS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjSolicitaRelatorioBeneficiosPagar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjSolicitaRelatorioBeneficiosPagar->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmRelatorioBeneficiosPagar').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmRelatorioBeneficiosPagar');";  }
		
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro.'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
			
	}   
		
	exibirErro('inform','Solicita&ccedil;&atilde;o efetuada com sucesso. Em alguns instantes o relat&oacute;rio estar&aacute; dispon&iacute;vel na op&ccedil;&atilde;o Visualizar.','Alerta - Aimaro','controlaVoltar(\'V8\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);		
	
			
?>



				


				

