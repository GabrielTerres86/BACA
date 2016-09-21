<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para manter as operações da tela CADTAR
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
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cddopdet       = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : '' ;	
	$cdfaixav		= (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0  ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$vlinifvl		= (isset($_POST['vlinifvl'])) ? $_POST['vlinifvl'] : 0  ;	
	$vlfinfvl		= (isset($_POST['vlfinfvl'])) ? $_POST['vlfinfvl'] : 0  ;	
	$cdhistor		= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0  ;	
	$cdhisest		= (isset($_POST['cdhisest'])) ? $_POST['cdhisest'] : 0  ;	
	$cddopcao		= (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : '' ;	
								
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopdet) {
		case 'C': $procedure = 'buscar-cadfvl';	 break;
		case 'I': $procedure = 'incluir-cadfvl'; break;
		case 'A': $procedure = 'alterar-cadfvl'; break;
		case 'E': $procedure = 'excluir-cadfvl'; break;
	}
	
	if ( $cddopdet == 'E' ) {
		$retornoAposErro = 'unblockBackground()';
	} else {
		$retornoAposErro = 'focaCampoErro(\'vlinifvl\', \'frmDetalhaTarifa\');bloqueiaFundo($(\'#divRotina\'));';
	}
	
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
	$xml .= '		<cdfaixav>'.$cdfaixav.'</cdfaixav>';
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';
	$xml .= '		<vlinifvl>'.$vlinifvl.'</vlinifvl>';
	$xml .= '		<vlfinfvl>'.$vlfinfvl.'</vlfinfvl>';
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<cdhisest>'.$cdhisest.'</cdhisest>';	
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
	
	//$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];
	
	if ($cddopdet == "C"){
		echo "$('#dscatego','#frmCab').val('$dscatego');";
		echo "$('#cddgrupo','#frmCab').focus();";
		echo "$('#vlinifvl','#divTabDetalhamento').desabilitaCampo();";
		echo "$('#vlfinfvl','#divTabDetalhamento').desabilitaCampo();";
		echo "$('#cdhistor','#divTabDetalhamento').desabilitaCampo();";
		echo "$('#cdhisest','#divTabDetalhamento').desabilitaCampo();";
		echo "trocaBotao('');";
	}
	
	if ($cddopdet == "I"){
		echo "$('#vlinifvl','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#vlfinfvl','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#cdhistor','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#cdhisest','#frmDetalhaTarifa').desabilitaCampo();";
		echo 'showError("inform","Detalhamento Tarifa incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusaoDet(); liberaDetalhamento(); ");';				
	}
	
	if ($cddopdet == "A"){
		echo "$('#vlinifvl','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#vlfinfvl','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#cdhistor','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#cdhisest','#frmDetalhaTarifa').desabilitaCampo();";
		echo 'showError("inform","Detalhamento Tarifa alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));liberaDetalhamento();");';	
	}
	
	if ($cddopdet == "E"){
		echo 'showError("inform","Detalhamento Tarifa excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaDetalhamento();");';		
	}

			
?>
