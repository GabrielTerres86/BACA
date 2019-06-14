<? 
/*!
 * FONTE        : busca_historico.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 18/03/2013 
 * OBJETIVO     : Rotina para buscar historico RELTAR
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
	$procedure = 'busca-historico-tarifa';
	
	$retornoAposErro = 'focaCampoErro(\'cdhistor\', \'frmReltar\');';
	
	$cddopcao = 'C';
	
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
	
	echo "if( $('#tprelato','#frmCab').val() == 3 ){";
	echo "	$('#dshisest','#frmReltar').val('$dshistor');";
	echo "	$('#cdhisest','#frmReltar').desabilitaCampo();";
	echo "	$('#cdagenci','#frmReltar').focus();";		
	echo "}else{";
	echo "	$('#dshistor','#frmReltar').val('$dshistor');";
	echo "	$('#cdhistor','#frmReltar').desabilitaCampo();";
	echo "	$('#cdagenci','#frmReltar').focus();";		
	echo "}";
			
?>
