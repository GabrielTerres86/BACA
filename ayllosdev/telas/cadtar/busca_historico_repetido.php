<? 
/*!
 * FONTE        : busca_historico_repetido.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 18/03/2013 
 * OBJETIVO     : Rotina para buscar historico craphis
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
	$cdhistor		= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0  ; 
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'busca-historico-repetido';
	
	$retornoAposErro = 'focaCampoErro(\'cdhistor\', \'frmDetalhaTarifa\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
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
	
	$dshistor = $xmlObjeto->roottag->tags[0]->attributes["DSHISTOR"];
	$cdhisest = $xmlObjeto->roottag->tags[0]->attributes["CDHISEST"];
	$dshisest = $xmlObjeto->roottag->tags[0]->attributes["DSHISEST"];
	
	echo "$('#dshistor','#frmDetalhaTarifa').val('$dshistor');";

	if($cdhisest > 0){				
		echo "$('#cdhisest','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#dshisest','#frmDetalhaTarifa').desabilitaCampo();";
		echo "$('#cdhisest','#frmDetalhaTarifa').val('$cdhisest');";
		echo "$('#dshisest','#frmDetalhaTarifa').val('$dshisest');";

	//	echo "$('#cdhisest','#frmDetalhaTarifa').focus();";			
	} else {
		echo "$('#cdhisest','#frmDetalhaTarifa').habilitaCampo();";
	//	echo "$('#cdhisest','#frmDetalhaTarifa').focus();";		
	
	}
	
			
?>
