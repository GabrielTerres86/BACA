<?php
/*!
 * FONTE        : manter_municipios.php                    Última alteração: 
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Agosto/2016 
 * OBJETIVO     : Rotina para incluir/alterar municipios
 * --------------
 * ALTERAÇÕES   :  
 */
?>

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
  $tpoperac = (isset($_POST["tpoperac"])) ? $_POST["tpoperac"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
  
  if($tpoperac == 'I'){
  
    $dscidade = (isset($_POST["dscidade"])) ? $_POST["dscidade"] : '';
    $cdestado = (isset($_POST["cdestado"])) ? $_POST["cdestado"] : '';    
        
  }else{
  
      $cdcidade = (isset($_POST["cdcidade"])) ? $_POST["cdcidade"] : '';
          
  }
   
  validaDados();
   
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <cdcidade>".$cdcidade."</cdcidade>";
  $xml 	   .= "     <dscidade>".$dscidade."</dscidade>";
  $xml 	   .= "     <cdestado>".$cdestado."</cdestado>";
  $xml 	   .= "     <tpoperac>".$tpoperac."</tpoperac>";
  $xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADCOP", "MANTERMUN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
    if($tpoperac == 'I'){
    
      $nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		  if(empty ($nmdcampo)){ 
			  $nmdcampo = "dscidade";
		  }
		    
		  exibirErro('error',$msgErro,'Alerta - Ayllos','focaCampoErro(\''.$nmdcampo.'\',\'frmIncluir\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
		
    }else{
      
      exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesMunicipios\').focus();',false);		
      
    }
    
	} 
		    
  if($tpoperac == 'I'){
  
    exibirErro('inform','Munic&iacute;pio incluido com sucesso.','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));consultaMunicipios(\'1\',\'30\');', false);  
    
  }else{
      
     exibirErro('inform','Munic&iacute;pio excluido com sucesso.','Alerta - Ayllos','consultaMunicipios(\'1\',\'30\');', false);  
      
  }
  
 
	  
  function validaDados(){
    
    if ( $GLOBALS["tpoperac"] == 'E'){ 
    
      //Código da cidade
		  if ( $GLOBALS["cdcidade"] == ''){ 
			  exibirErro('error','C&oacute;digo da cidade inv&aacute;lido.','Alerta - Ayllos','$("#btVoltar","#divBotoesMunicipios").focus();',false);
		  }
      
    }else{
    
      //Nome da cidade
		  if ( $GLOBALS["dscidade"] == ''){ 
			  exibirErro('error','Nome da cidade inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'dscidade\', \'frmIncluir\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		  }
      
      //UF da cidade
		  if ( $GLOBALS["cdestado"] == ''){ 
			  exibirErro('error','UF da cidade inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'cdestado\', \'frmIncluir\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		  }      
      
    }
    
  }
  
 ?>
