<? 
/*!
 * FONTE        : busca_dados_tarifa.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para buscar dados da tarifa na tela CADTAR
 * --------------
 * ALTERAÇÕES   : 21/08/2013 - Busca do campo cdtipcat (Daniel).
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
	
	// Recebe a operação que está sendo realizada
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$procedure      = 'buscar-cadtar';
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
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
	$flgpacta = $xmlObjeto->roottag->tags[0]->attributes["FLGPACTA"];
	
	$cdtipcat = $xmlObjeto->roottag->tags[0]->attributes["CDTIPCAT"];
	
	$incidencia = $xmlObjeto->roottag->tags[0]->tags;
	
	
	echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
	echo "$('#dssubgru','#frmCab').val('$dssubgru');";
	echo "$('#cdcatego','#frmCab').val('$cdcatego');";
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	echo "$('#dstarifa','#frmCab').val('$dstarifa');";
	echo "$('#inpessoa','#frmCab').val('$inpessoa');";
	echo "$('#cdinctar','#frmCab').val('$cdinctar');";
	
	echo "$('#cdtipcat','#frmCab').val('$cdtipcat');";
	
	if ( $flglaman == 'yes' ){	
		echo "$('#flglaman','#frmCab').prop('checked',true);";
	}
	
	if ( $flgpacta == 'yes' ){	
		echo "$('#flgpacta','#frmCab').prop('checked',true);";
	}
	
	
	echo "$('#cdocorre','#frmCab').val('$cdocorre');";
	echo "$('#cdmotivo','#frmCab').val('$cdmotivo');";
	
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	
	echo "$('#divOcorrenciaMotivo').css({'display':'block'});";
		
	if ( ($cddopcao == "C") || ($cddopcao == "X") ){
		echo "$('#cdtarifa','#frmCab').desabilitaCampo();";
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcad','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "$('#cdcatego','#frmCab').desabilitaCampo();";
	}
	
	echo "trocaBotao('');";
	
	if ($cddopcao == "A"){
		echo "trocaBotao('Alterar');";
		echo "$('#inpessoa','#frmCab').focus();";
		echo "$('#cdtarifa','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdcatego','#frmCab').desabilitaCampo();";
		echo "$('#inpessoa','#frmCab').habilitaCampo();";
		echo "$('#cdinctar','#frmCab').habilitaCampo();";
		echo "$('#cdocorre','#frmCab').habilitaCampo();";
		echo "$('#cdmotivo','#frmCab').habilitaCampo();";
		echo "$('#flglaman','#frmCab').habilitaCampo();";
	}
	
	if ($cddopcao == "E"){
		echo "$('#cdtarifa','#frmCab').desabilitaCampo();";
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcad','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "$('#cdcatego','#frmCab').desabilitaCampo();";
		echo "trocaBotao('Excluir');";
	}
	

			
?>
