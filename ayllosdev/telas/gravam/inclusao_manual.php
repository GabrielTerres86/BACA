<?php
/*!
 * FONTE        : inclusao_manual.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para realizar inclusão manual do gravame
 * --------------
 * ALTERAÇÕES   : 24/08/2016 - Alteração da descricao de confirmação da inclusao manual. Projeto 369 (Lombardi).
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
  $dtmvttel = (isset($_POST["dtmvttel"])) ? $_POST["dtmvttel"] : '';
  $nrgravam = (isset($_POST["nrgravam"])) ? $_POST["nrgravam"] : 0;
  $tpctrpro = (isset($_POST["tpctrpro"])) ? $_POST["tpctrpro"] : 0;
  $idseqbem = (isset($_POST["idseqbem"])) ? $_POST["idseqbem"] : 0;
	$dsjustif = (isset($_POST["dsjustif"])) ? $_POST["dsjustif"] : '';
	$tpinclus = (isset($_POST["tpinclus"])) ? $_POST["tpinclus"] : '';
  
	validaDados($tpinclus);
  
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
  $xml 	   .= "     <dtmvttel>".$dtmvttel."</dtmvttel>";
if ($tpinclus == "M") {
  $xml 	   .= "     <dsjustif>".$dsjustif."</dsjustif>";
	$xml       .= "     <tpinclus>".$tpinclus."</tpinclus>";
	$xml       .= "     <cdopeapr>".$_SESSION['cdopelib']."</cdopeapr>";
} else {
	$xml 	   .= "     <dsjustif></dsjustif>";
	$xml       .= "     <tpinclus>".$tpinclus."</tpinclus>";
	$xml       .= "     <cdopeapr></cdopeapr>";
}
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "INCMANUALGRAVAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    $nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
    
    if(empty ($nmdcampo)){ 
			$nmdcampo = "dtmvttel";
		}
    
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFormularioBens();focaCampoErro(\''.$nmdcampo.'\',\'frmBens\');',false);		
					
	} else {
		if ($tpinclus == "M") {
			$msgReturn = utf8ToHtml('Inclus&atilde;o manual do registro efetuada com sucesso! Ao efetuar uma aliena&ccedil;&atilde;o manual, &eacute; necess&aacute;rio efetuar a aliena&ccedil;&atilde;o manual no sistema CETIP');
		} else {
			$msgReturn = utf8ToHtml('Alienação efetuada com sucesso!');
	} 
		echo "showError('inform','".$msgReturn."','Notifica&ccedil;&atilde;o - Aimaro','buscaBens(1, 30);');";
	}
	echo '$(\'#ddl_descrbem', '#frmBens\').change();';
	  
	function validaDados($tpinclus) {
	  
		IF($GLOBALS["dtmvttel"] == '' ) {
			exibirErro('error','Data do registro deve ser informada!.','Alerta - Aimaro','focaCampoErro(\'dtmvttel\',\'frmBens\');',false);
		}
    
		IF($GLOBALS["dsjustif"] == '' && $tpinclus != "A") {
			exibirErro('error','Justificativa deve ser informada!'.$tpinclus ,'Alerta - Aimaro','focaCampoErro(\'dsjustif\',\'frmBens\');',false);
		}
    
		IF($GLOBALS["nrgravam"] == 0) {
			exibirErro('error','O n&uacute;mero do registro não foi informado!','Alerta - Aimaro','focaCampoErro(\'nrgravam\',\'frmBens\');',false);
		}
	}	
  
 ?>
