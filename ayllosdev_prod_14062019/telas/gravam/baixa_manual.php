<?php
/*!
 * FONTE        : baixa_manual.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para a baixa manual do gravame
 * --------------
 * ALTERAÇÕES   : 24/08/2016 - Alteração da descricao de confirmação da baixa manual. Projeto 369 (Lombardi).
 * ALTERAÇÕES	: Outubro/2018 - Alteração para fazer a Baixa através do serviço SOA antes. (Thaise - Envolti)
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
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
  $nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
  $nrgravam = (isset($_POST["nrgravam"])) ? $_POST["nrgravam"] : 0;
  $tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
  $dsjstbxa = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
  $tpdopcao = (isset($_POST["tpdopcao"])) ? $_POST["tpdopcao"] : '';
  
	if($tpdopcao == 'A'){
		// Montar o xml de Requisicao
		$xmlCarregaDados  = "";
		$xmlCarregaDados .= "<Root>";
		$xmlCarregaDados .= " <Dados>";
		$xmlCarregaDados .= " </Dados>";
		$xmlCarregaDados .= "</Root>";

		$xmlResult = mensageria($xmlCarregaDados
							   ,"GRVM0001"
							   ,"GRAVAME_ONLINE_HABILITADO"
							   ,$glbvars["cdcooper"]
							   ,$glbvars["cdagenci"]
							   ,$glbvars["nrdcaixa"]
							   ,$glbvars["idorigem"]
							   ,$glbvars["cdoperad"]
							   ,"</Root>");
		$xmlObject = getObjectXML($xmlResult);

		if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
			$flgGrvOnline = "ERRO";
		} else if (strtoupper($xmlObject->roottag->tags[0]->name) == "GRVONLINE") {
			$flgGrvOnline = $xmlObject->roottag->tags[0]->cdata;
		}
	}
  
	if( ($tpdopcao == 'A' && $flgGrvOnline == 'S') || $tpdopcao == 'M') {
  
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
  	$xml 	   .= "     <tpdbaixa>".$tpdopcao."</tpdbaixa>"; 
  $xml 	   .= "     <nrgravam>".$nrgravam."</nrgravam>";      
  	$xml       .= "     <cdopeapr>".$_SESSION['cdopelib']."</cdopeapr>";   
  $xml 	   .= "     <dsjstbxa>".$dsjstbxa."</dsjstbxa>"; 
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "BAIXAMANUAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','focaCampoErro(\'dsjstbxa\',\'frmBens\');',false);		
	} 
	}
		
	if($tpdopcao == 'A' && $flgGrvOnline == 'S') {
		parametrosParaAudit($glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"]);
		processarBaixaCancel($xmlResult, 3, $Url_SOA, $Auth_SOA);
	} else if ($tpdopcao == 'M') {
		echo "showError('inform','Registro de baixa manual efetuada com sucesso! Ao efetuar a baixa manual, &eacute; necess&aacute;rio efetuar a baixa manual no sistema CETIP.','Notifica&ccedil;&atilde;o - Aimaro','buscaBens(1, 30);');";
	} else {
		echo "showError('error','N&atilde;o &eacute; poss&iacute;vel baixar aliena&ccedil;&atilde;o automaticamente, o processo on-line n&atilde;o est&aacute; ativado.','Alerta - Aimaro','');";
	}
	echo '$(\'#ddl_descrbem', '#frmBens\').change();';
	  
  
  function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','focaCampoErro(\'nrdconta\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["nrctrpro"] == '' ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrctrpro\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["nrgravam"] == '' ){ 
			exibirErro('error','N&uacute;mero do gravame inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'nrgravam\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["tpctrpro"] == 0 ){ 
			exibirErro('error','Tipo do contrato inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'tpctrpro\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["idseqbem"] == 0 ){ 
			exibirErro('error','C&oacute;digo do bem inv&aacute;lido.','Alerta - Aimaro','focaCampoErro(\'idseqbem\',\'frmBens\');',false);
		}
    
    IF($GLOBALS["dsjstbxa"] == '' ){ 
			exibirErro('error','Justificativa da baixa deve ser informada.','Alerta - Aimaro','$(\'#dsjustif\', \'#divJustificativa\').habilitaCampo();focaCampoErro(\'dsjustif\',\'frmBens\');',false);
		}
	}	
  
 ?>
