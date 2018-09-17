<? 
/*!
 * FONTE        : cria_dados_totvs.php
 * CRIAÇÃO      : Lucas R. 
 * DATA CRIAÇÃO : Maio/2013 
 * OBJETIVO     : Rotina para criar, alterar e excluir dados da tela CADBND
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Cadbnd','',false);
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0147.p</Bo>";
	$xml .= "		<Proc>cria_dados_totvs</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
			exibirErro('error',$msgErro,'Alerta - Cadbnd',$mtdErro,false);
	}	

?>
