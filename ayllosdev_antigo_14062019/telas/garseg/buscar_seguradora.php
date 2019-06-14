<? 
/*
 * FONTE        : buscar_seguradora.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida (GATI)
 * DATA CRIAÇÃO : 19/10/2011 
 * OBJETIVO     : Rotina para buscar o nome da seguradora a partir do código na tela GARSEG
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?php
	session_start();
	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');		
   
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	
	$cdsegura = (isset($_POST['cdsegura'])) ? $_POST['cdsegura'] : '' ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError.'teste','Alerta - Garseg','',false);
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0033.p</Bo>";
	$xml .= "		<Proc>buscar_seguradora</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nmsegura\',\'#frmGarseg\').val(\'\');$(\'#cdsegura\',\'#frmGarseg\').focus();',false);
	}	

	echo "buscaSeguradora();";
?>
