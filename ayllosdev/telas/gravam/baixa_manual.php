<?php
/*!
 * FONTE        : baixa_manual.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para a baixa manual do gravame
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
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
  
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $nrgravam = (isset($_POST["nrgravam"])) ? $_POST["nrgravam"] : 0;
  $tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
  $dsjstbxa = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
  
  
  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>";   
  $xml 	   .= "     <tpctrpro>".$tpctrpro."</tpctrpro>";  
  $xml 	   .= "     <idseqbem>".$idseqbem."</idseqbem>";    
  $xml 	   .= "     <nrgravam>".$nrgravam."</nrgravam>";      
  $xml 	   .= "     <dsjstbxa>".$dsjstbxa."</dsjstbxa>"; 
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "BAIXAMANUAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','focaCampoErro(\'dsjstbxa\',\'frmBens\');',false);		
					
	} 
		
  echo "showError('inform','Registro de Baixa Manual efetuada com sucesso!','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
	  
  
  function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos',' $(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["nrctrpro"] == '' ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["nrgravam"] == '' ){ 
			exibirErro('error','N&uacute;mero do gravame inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["tpctrpro"] == 0 ){ 
			exibirErro('error','Tipo do contrato inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["idseqbem"] == 0 ){ 
			exibirErro('error','C&oacute;digo do bem inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);
		}
    
    IF($GLOBALS["dsjstbxa"] == '' ){ 
			exibirErro('error','Justificativa da baixa deve ser informada.','Alerta - Ayllos','formataFormularioBens();',false);
		}
				
	}	
  
 ?>