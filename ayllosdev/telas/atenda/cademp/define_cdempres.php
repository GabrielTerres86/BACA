<?php 
/*!
 * FONTE        : define_cdempres.php
 * CRIAÇÃO      : Cristian Filipe       
 * DATA CRIAÇÃO :  
 * OBJETIVO     : Rotina para fazer a busca da tabela de empresas
 * --------------
 * ALTERAÇÕES   : Ajustes conforme SD 122814
 *				  28/07/2016 - Correcao na forma de utilizacao das variavies do array $glbvars. SD 491925. (Carlos R.)	
 * -------------- 
 */	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = $_POST['cddopcao'];

	$cdcooper = ( isset($glbvars["cdcooper"]) ) ? $glbvars["cdcooper"] : '';
	$cdagenci = ( isset($glbvars["cdagenci"]) ) ? $glbvars["cdagenci"] : '';
	$nrdcaixa = ( isset($glbvars["nrdcaixa"]) ) ? $glbvars["nrdcaixa"] : '';
	$cdoperad = ( isset($glbvars["cdoperad"]) ) ? $glbvars["cdoperad"] : '';
	$dtmvtolt = ( isset($glbvars["dtmvtolt"]) ) ? $glbvars["dtmvtolt"] : '';
	$idorigem = ( isset($glbvars["idorigem"]) ) ? $glbvars["idorigem"] : '';
	$nmdatela = ( isset($glbvars["nmdatela"]) ) ? $glbvars["nmdatela"] : '';
	$cdprogra = ( isset($glbvars["cdprogra"]) ) ? $glbvars["cdprogra"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$xml  = '';
	$xml .= '<Root>';
	$xml .= '  <Cabecalho>';
	$xml .= '	    <Bo>b1wgen0166.p</Bo>';
	$xml .= "        <Proc>Define_cdempres</Proc>";
	$xml .= '  </Cabecalho>';
	$xml .= '  <Dados>';
	$xml .= "        <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "        <cdagenci>".$cdagenci."</cdagenci>";
	$xml .= "        <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
	$xml .= "        <cdoperad>".$cdoperad."</cdoperad>";
	$xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	$xml .= "        <idorigem>".$idorigem."</idorigem>";
	$xml .= "        <nmdatela>".$nmdatela."</nmdatela>";
	$xml .= "        <cdprogra>".$cdprogra."</cdprogra>";
	$xml .= '  </Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata : '';
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$registros = ( isset($xmlObjeto->roottag->tags[0]->tags) ) ? $xmlObjeto->roottag->tags[0]->tags : array();
	$cdempres  = ( isset($xmlObjeto->roottag->tags[0]->attributes['CDEMPRES']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CDEMPRES'] : '';

	echo "$('#cdempres', '#frmInfEmpresa').val('{$cdempres}');";
			
?>
