<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para buscar grupo na tela CADTAR
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
	$cddgrupo		= (isset($_POST['cddgrupo'])) ? $_POST['cddgrupo'] : 0  ;
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdsubgru		= (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0  ; 
	$dscatego		= (isset($_POST['dscatego'])) ? $_POST['dscatego'] : 0  ; 
	$cdtipcad       = (isset($_POST['cdtipcad'])) ? $_POST['cdtipcad'] : 0  ; 	
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-cadtar';
	
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
	$xml .= '		<cddgrupo>'.$cddgrupo.'</cddgrupo>';
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
	$xml .= '		<cdtipcad>'.$cdtipcad.'</cdtipcad>';
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
	$xml .= '		<dscatego>'.$dscatego.'</dscatego>';
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
	
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	echo "$('#dscatego','#frmCab').habilitaCampo();";
	echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	echo "$('#dscatego','#frmCab').focus();";
	
	echo "trocaBotao('');";
		
	if ($cddopcao == "A"){
		echo "trocaBotao('Alterar');";
	}
	
	if ($cddopcao == "E"){
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdcatego','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcad','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
			
?>
