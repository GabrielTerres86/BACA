<? 
/*!
 * FONTE        : busca_dados_categoria.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 04/03/2013 
 * OBJETIVO     : Rotina para buscar CADCAT
 * --------------
 * ALTERAÇÕES   : 
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
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ;	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadcat';
	
	$retornoAposErro = 'focaCampoErro(\'cdcatego\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
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
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
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
	
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];
	$cdsubgru = $xmlObjeto->roottag->tags[0]->attributes["CDSUBGRU"];
	$dsdgrupo = $xmlObjeto->roottag->tags[0]->attributes["DSDGRUPO"];
	$dssubgru = $xmlObjeto->roottag->tags[0]->attributes["DSSUBGRU"];
	$cddgrupo = $xmlObjeto->roottag->tags[0]->attributes["CDDGRUPO"];	
	$cdtipcat = $xmlObjeto->roottag->tags[0]->attributes["CDTIPCAT"];
	$dstipcat = $xmlObjeto->roottag->tags[0]->attributes["DSTIPCAT"];
	
	if ( $cddgrupo == 0 ) {
		$cddgrupo = '';
	}
		
	if ( $cdsubgru == 0 ) {
		$cdsubgru = '';	
	}
	
	echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	echo "$('#cdtipcat','#frmCab').val('$cdtipcat');";
	echo "$('#dstipcat','#frmCab').val('$dstipcat');";
	echo "$('#dssubgru','#frmCab').val('$dssubgru');";
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
	
	echo "$('#dscatego','#frmCab').desabilitaCampo();";
	echo "$('#cdcatego','#frmCab').desabilitaCampo();";
	echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
	echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	echo "$('#dssubgru','#frmCab').desabilitaCampo();";
	echo "$('#cdtipcat','#frmCab').desabilitaCampo();";
	echo "$('#dstipcat','#frmCab').desabilitaCampo();";
	
	if ( $cddopcao == 'A' ){
		echo "$('#dscatego','#frmCab').habilitaCampo();";		
		echo "trocaBotao('Alterar');";
	}

	echo "$('#dscatego','#frmCab').focus();";	
	
	if ( $cddopcao == 'E' ){
		echo "trocaBotao('Excluir');";
	}
	
	if ( $cddopcao == 'C' ){
		echo "trocaBotao('');";
	}
	
			
?>
