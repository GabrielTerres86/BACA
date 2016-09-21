<? 
/*!
 * FONTE        : busca_dados_subgrupo.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 28/02/2013 
 * OBJETIVO     : Rotina para buscar subgrupo na tela CADTAR
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
	$cdsubgru		= (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0  ; 

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadsgr';
	
	$retornoAposErro = 'focaCampoErro(\'cdsubgru\', \'frmCab\');';
	
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
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
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
	$cddgrupo = $xmlObjeto->roottag->tags[0]->attributes["CDDGRUPO"];
	
	echo "$('#dssubgru','#frmCab').val('$dssubgru');";
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";	
	
	echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
	echo "$('#dssubgru','#frmCab').desabilitaCampo();";
	
	echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	
	echo "$('#cdcatego','#frmCab').habilitaCampo();";
	echo "$('#cdcatego','#frmCab').focus();";
		
	// echo "trocaBotao('');";
		
	if ($cddopcao == "A"){
	//	echo "trocaBotao('Alterar');";		
	}	
	
	if ($cddopcao == "E"){
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "$('#dssubgru','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
			
?>
