<? 
/*!
 * FONTE        : busca_dados_categoria.php
 * CRIA��O      : Daniel Zimmermann         
 * DATA CRIA��O : 04/03/2013 
 * OBJETIVO     : Rotina para buscar categoria na tela ALTTAR
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
	
	// Recebe a opera��o que est� sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ;	

	// Dependendo da opera��o, chamo uma procedure diferente
	$procedure = 'buscar-cadcat';
	
	$retornoAposErro = 'focaCampoErro(\'cdcatego\', \'frmCab\');';
	
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
	
	$dssubgru = $xmlObjeto->roottag->tags[0]->attributes["DSSUBGRU"];
	$dsdgrupo = $xmlObjeto->roottag->tags[0]->attributes["DSDGRUPO"];
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];
	$cddgrupo = $xmlObjeto->roottag->tags[0]->attributes["CDDGRUPO"];
	$cdsubgru = $xmlObjeto->roottag->tags[0]->attributes["CDSUBGRU"];
	$cdtipcat = $xmlObjeto->roottag->tags[0]->attributes["CDTIPCAT"];
	
	if($dssubgru <> ''){
		echo "$('#dssubgru','#frmCab').val('$dssubgru');";
		echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
		echo "$('#dssubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	}
	
	if($dsdgrupo <> ''){
		echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
		echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
		echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	}
	
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	
	echo "$('#cdtipcat','#frmCab').val('$cdtipcat');";
	
	echo "$('#dscatego','#frmCab').desabilitaCampo();";
	echo "$('#cdcatego','#frmCab').desabilitaCampo();";
	
    if ($cdcatego == 2) { // Cobranca
        echo "$('#linCobranca','#frmCab').show();";
        echo "$('#nrconven','#frmCab').habilitaCampo().focus();";
    } elseif ($cdcatego == 3) { // Emprestimo
        echo "$('#linEmprestimo','#frmCab').show();";
        echo "$('#cdlcremp','#frmCab').habilitaCampo().focus();";
    } else {
        echo "$('#dtdivulg','#frmCab').habilitaCampo().focus();";
    }

    echo "btnContinuar();";
?>
