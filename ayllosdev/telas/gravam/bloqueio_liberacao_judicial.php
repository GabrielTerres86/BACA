<?php
/*!
 * FONTE        : bloqueio_liberacao_judicial.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para realizar o bloqueio/liberação judicial do gravame
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
	$tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $dschassi = (isset($_POST["dschassi"])) ? $_POST["dschassi"] : '';  
  $ufdplaca = (isset($_POST["ufdplaca"])) ? $_POST["ufdplaca"] : '';
  $nrdplaca = (isset($_POST["nrdplaca"])) ? $_POST["nrdplaca"] : '';
  $nrrenava = (isset($_POST["nrrenava"])) ? $_POST["nrrenava"] : 0;
	$dsjustif = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
    
  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>"; 
  $xml 	   .= "     <idseqbem>".$idseqbem."</idseqbem>";
  $xml 	   .= "     <tpctrpro>".$tpctrpro."</tpctrpro>";
  $xml 	   .= "     <dschassi>".$dschassi."</dschassi>";
  $xml 	   .= "     <ufdplaca>".$ufdplaca."</ufdplaca>";
	$xml 	   .= "     <nrdplaca>".$nrdplaca."</nrdplaca>";
  $xml 	   .= "     <nrrenava>".$nrrenava."</nrrenava>";
	$xml 	   .= "     <dsjustif>".$dsjustif."</dsjustif>";
  if($cddopcao == 'J'){
  
    // 0-> Bloquear
    $xml 	   .= "     <flblqjud>1</flblqjud>";
    
  }else if($cddopcao == 'L'){
  
     //1-> Liberar
     $xml 	   .= "     <flblqjud>0</flblqjud>";
  
  }  
  $xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	

	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "BLQLIBGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);		
					
	} 
		
	
			
  //Se for boqueio judicial
  if($cddopcao == "J"){ 
  
    echo "showError('inform','Bloqueio do bem registrado com sucesso.','Notifica&ccedil;&atilde;o - Aimaro','buscaBens(1, 30);');";
        
  //Liberação judicial      
  }else{
  
    echo "showError('inform','Desbloqueio do bem registrado com sucesso!','Notifica&ccedil;&atilde;o - Aimaro','buscaBens(1, 30);');";	
    
  }
	  
  
  function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro',' $(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["nrctrpro"] == '' ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["cddopcao"] == 'J' && $GLOBALS["dsblqjud"] == 'SIM' ){ 
			exibirErro('error','Bloqueio do bem j&aacute; registrado.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF ( ($GLOBALS["cddopcao"] == 'L' && $GLOBALS["dsblqjud"] == 'NAO')){
      exibirErro('error','Libera&ccedil;&atilde;o do bem j&aacute; registrada.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);    
    
    }
    
    IF($GLOBALS["tpctrpro"] == 0 ){ 
			exibirErro('error','Tipo do contrato inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["idseqbem"] == 0 ){ 
			exibirErro('error','C&oacute;digo do bem inv&aacute;lido.','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["dschassi"] == '' ||  $GLOBALS["ufdplaca"] == '' || $GLOBALS["nrdplaca"] == '' || $GLOBALS["nrrenava"] == 0){ 
			exibirErro('error','Chassi, UF, Nr. da Placa e Renavam s&atilde;o obrigat&oacute;rios!','Alerta - Aimaro','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
		IF($GLOBALS["dsjustif"] == '' ){ 
			exibirErro('error','Justificativa inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'dsjustif\',\'frmBens\');',false);
		}
				
	}	
  
 ?>