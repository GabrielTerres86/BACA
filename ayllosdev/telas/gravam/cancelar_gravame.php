<?php
/*!
 * FONTE        : cancelar_gravame.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para cancelar alienação no gravame
 * --------------
 * ALTERAÇÕES   : Outubro/2018 - Alteração para fazer o cancelamento pelo serviço SOA. (Thaise - Envolti)
 */
?> 

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	require_once('uteis/funcoes_gravame.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
  
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
  $tpcancel = (isset($_POST["tpcancel"])) ? $_POST["tpcancel"] : 0;
  $dsjustif = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
  $tpdopcao = (isset($_POST["tpdopcao"])) ? $_POST["tpdopcao"] : '';
  
  
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
	$xml 	   .= "     <tpcancel>".$tpdopcao."</tpcancel>";
	$xml 	   .= "     <dsjustif>".$dsjustif."</dsjustif>";
	$xml 	   .= "     <cdopeapr>".$_SESSION['cdopelib']."</cdopeapr>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "CANCELARGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesBens\').focus();',false);		
					
	} 

	if($tpdopcao == 'A'){
		parametrosParaAudit($glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"]);
		processarBaixaCancel($xmlResult, 2, $Url_SOA, $Auth_SOA);
	} else {
		/* if($tpcancel == "1"){
    		echo "showError('inform','Solicita&ccedil;&atilde;o de cancelamento efetuada com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";
  		} else{
    		echo "showError('inform','Registro de aliena&ccedil;&atilde;o do gravame cancelado com sucesso.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";	
  		}*/
		echo "showError('inform','Registro de cancelamento manual efetuada com sucesso! Ao efetuar o cancelamento manual, &eacute; necess&aacute;rio efetuar o cancelamento manual no sistema CETIP.','Notifica&ccedil;&atilde;o - Ayllos','buscaBens(1, 30);');";
	}
	echo '$(\'#ddl_descrbem', '#frmBens\').change();';
	  
  
  function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'nrdconta\',\'frmBens\');',false);
		}
    
    	IF($GLOBALS["nrctrpro"] == '' ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'nrctrpro\',\'frmBens\');',false);
		}
    
    	IF($GLOBALS["tpcancel"] != '1' && $GLOBALS["tpcancel"] != '2'){ 
			exibirErro('error','Tipo de cancelamento inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'tpcancel\',\'frmBens\');',false);
		}
    
    	IF($GLOBALS["tpctrpro"] == 0 ){ 
			exibirErro('error','Tipo do contrato inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'tpctrpro\',\'frmBens\');',false);
		}
    
    	IF($GLOBALS["idseqbem"] == 0 ){ 
			exibirErro('error','C&oacute;digo do bem inv&aacute;lido.','Alerta - Ayllos','focaCampoErro(\'idseqbem\',\'frmBens\');',false);
		}
		
		IF($GLOBALS["dsjustif"] == '' ){ 
			exibirErro('error','Justificativa inv&aacute;lida.','Alerta - Ayllos','$(\'#dsjustif\', \'#divJustificativa\').habilitaCampo();focaCampoErro(\'dsjustif\',\'frmBens\');',false);
		}		
	}	
  
 ?>