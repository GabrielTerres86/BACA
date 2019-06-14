<? 
/*!
 * FONTE        : carrega_tab_pessoa_fisica.php
 * CRIAÇÃO      : Tiago Machado
 * DATA CRIAÇÃO : 26/03/2013
 * OBJETIVO     : Gera form com tarifas pessoa fisica.
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?> 

<?php

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$retornoAposErro	= 'cNrdconta.focus();';
	$procedure			= 'lista-tarifa-pessoa';


	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<inpessoa>1</inpessoa>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	} 
 
	$tarifas_count = count($xmlObjeto->roottag->tags[0]->tags);		
	
	for ($i = 0; $i < $tarifas_count; $i++){		
		$tarifas   = $xmlObjeto->roottag->tags[0]->tags[$i]->tags;	
		$cdtarifa = getByTagName($tarifas,'cdtarifa');		
		$dstarifa = getByTagName($tarifas,'dstarifa');
		$cdhistor = getByTagName($tarifas,'cdhistor');
		$dshistor = getByTagName($tarifas,'dshistor');
		$vltarifa = getByTagName($tarifas,'vltarifa');	
		$cdfvlcop = getByTagName($tarifas,'cdfvlcop');	
		$bloqueia = getByTagName($tarifas,'bloqueia');
		
		echo "criaObjetoTarifaPf('$cdtarifa', '$dstarifa', '$cdhistor', '$dshistor', '$vltarifa', '$cdfvlcop', '$bloqueia');";
	}	

	echo	"carregaTabelaTarifaPf();";	
?>