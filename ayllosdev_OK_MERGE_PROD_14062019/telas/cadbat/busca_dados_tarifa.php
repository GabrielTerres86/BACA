<? 
/*!
 * FONTE        : busca_dados_tarifa.php
 * CRIA��O      : Tiago Machado          
 * DATA CRIA��O : 19/04/2013
 * OBJETIVO     : Rotina para buscar dados da tarifa na tela CADTAR
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a opera��o que est� sendo realizada
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$procedure      = 'buscar-cadtar';
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmDadosTarifa\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml din�mico de acordo com a opera��o 
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
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';
	$xml .= '		<flgerlog>YES</flgerlog>';
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
	
	$cddgrupo = $xmlObjeto->roottag->tags[0]->attributes["CDDGRUPO"];
	$dsdgrupo = $xmlObjeto->roottag->tags[0]->attributes["DSDGRUPO"];
	$cdsubgru = $xmlObjeto->roottag->tags[0]->attributes["CDSUBGRU"];
	$dssubgru = $xmlObjeto->roottag->tags[0]->attributes["DSSUBGRU"];
	$cdcatego = $xmlObjeto->roottag->tags[0]->attributes["CDCATEGO"];
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];	
	$dstarifa = $xmlObjeto->roottag->tags[0]->attributes["DSTARIFA"];
	$inpessoa = $xmlObjeto->roottag->tags[0]->attributes["INPESSOA"];
	$cdocorre = $xmlObjeto->roottag->tags[0]->attributes["CDOCORRE"];
	$cdmotivo = $xmlObjeto->roottag->tags[0]->attributes["CDMOTIVO"];
	$cdinctar = $xmlObjeto->roottag->tags[0]->attributes["CDINCTAR"];
	$flglaman = $xmlObjeto->roottag->tags[0]->attributes["FLGLAMAN"];	
	
	
	echo "$('#dstarifa','#frmDadosTarifa').val('$dstarifa');";
	echo "$('#inpessoa','#frmDadosTarifa').val('$inpessoa');";
	echo "$('#tppessoa','#frmDadosTarifa').val('$inpessoa');";		
	echo "$('#cddgrupo','#frmDadosTarifa').val('$cddgrupo');";
	echo "$('#dsdgrupo','#frmDadosTarifa').val('$dsdgrupo');";
	echo "$('#cdsubgru','#frmDadosTarifa').val('$cdsubgru');";
	echo "$('#dssubgru','#frmDadosTarifa').val('$dssubgru');";
	echo "$('#cdcatego','#frmDadosTarifa').val('$cdcatego');";
	echo "$('#dscatego','#frmDadosTarifa').val('$dscatego');";
	
	//echo "$('#cdtarifa','#frmDadosTarifa').desabilitaCampo();";
	
?>
