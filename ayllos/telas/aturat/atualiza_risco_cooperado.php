<?php 
	/*******************************************************************************
	 Fonte: atualiza_risco_cooperado.php                                                 
	 Autor: Andrei - RKAM                                                    
	 Data : Maio/2016                Última Alteração:  
	                                                                  
	 Objetivo  : Atualiza o risco do cooperado                                  
	                                                                  
	 Alterações: 
							  
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
  $flgatltl = isset($_POST["flgatltl"]) ? $_POST["flgatltl"] : 0;
		
  validaDados(); 
	
	// Monta o xml de requisição
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";	
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <flgatltl>".$flgatltl."</flgatltl>";
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";		
		
	$xmlResult = mensageria($xml, "TELA_ATURAT", "CALCATLRAT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
  $dsdrisco  = $xmlObj->roottag->tags[0]->tags[0]->tags[0]->cdata;
	
  
  if ($flgatltl == "0"){
  
    echo "showConfirmacao('O Risco do Cooperado ser&aacute; ".$dsdrisco.". Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos',' atualizaRiscoCooperado(\'1\');','controlaVoltar(\'3\');','sim.gif','nao.gif');";


  }else{
  
    echo "showError('inform','Novo Risco Cooperado atualizado para ".$dsdrisco.".','Notifica&ccedil;&atilde;o - Ayllos','estadoInicial(\'3\');');";	
		
  } 
  
    
  function validaDados(){
		
		
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','controlaVoltar(\'3\');focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
		}
			
						
	}	
  
?>
