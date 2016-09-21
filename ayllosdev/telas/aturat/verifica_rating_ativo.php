<?php 
	/*******************************************************************************
	 Fonte: verifica_rating_ativo.php                                                 
	 Autor: Andrei - RKAM                                                    
	 Data : Maio/2016                Última Alteração: 22/06/2016 
	                                                                  
	 Objetivo  : Verifica se o cooperado possui um rating ativo                                  
	                                                                  
	 Alterações: 22/06/2016 - Ajuste para apresentar o PA do cooperado
                            (Andrei - RKAM).
							  
	********************************************************************************/
	
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
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
		
  validaDados(); 
	
	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";	
	$xml 	   .= "     <dtmvtolt>".$dtmvtolt."</dtmvtolt>";	
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
		
	$xmlResult = mensageria($xml, "TELA_ATURAT", "VERRATATIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		

  //-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','controlaVoltar(\'3\'); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
	
	$registros =  $xmlObj->roottag->tags[0]->tags;
  $inrisctl = $xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata;
  $cdagenci = $xmlObj->roottag->tags[0]->tags[0]->tags[2]->cdata;
  
  echo "$('#divRiscoCooperado').css('display', 'block');";
  echo "$('#fsetRisco','#frmFiltro').css('display', 'block');";
  echo "$('#inrisctl','#frmFiltro').val('".$inrisctl."');";
  echo "$('#cdagenci','#frmFiltro').val('".$cdagenci."');";
  echo "$('#btConcluir', '#divBotoes').css({ 'display': 'inline' }).focus();";
  echo "$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });";  
        
  function validaDados(){
		
		
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'#nrdconta\',\'#frmFiltro\').habilitaCampo();focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
		}
			
						
	}	
  
?>
