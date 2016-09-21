<? 
/*!
 * FONTE        : busca_motivo.php
 * CRIA��O      : Daniel Zimmermann         
 * DATA CRIA��O : 08/03/2013 
 * OBJETIVO     : Rotina para buscar dados motivo na tela CADMET
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
	$cdmotest		= (isset($_POST['cdmotest'])) ? $_POST['cdmotest'] : 0  ; 

	// Dependendo da opera��o, chamo uma procedure diferente
	$procedure = 'buscar-cadmet';
	
	$retornoAposErro = 'focaCampoErro(\'cdmotest\', \'frmCab\');';
	
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
	$xml .= '		<cdmotest>'.$cdmotest.'</cdmotest>';
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
	
	$dsmotest = $xmlObjeto->roottag->tags[0]->attributes["DSMOTEST"];
	$tpaplica = $xmlObjeto->roottag->tags[0]->attributes["TPAPLICA"];
		
	echo "$('#dsmotest','#frmCab').val('$dsmotest');";
	echo "$('#tpaplica','#frmCab').val('$tpaplica');";
	echo "$('#cdmotest','#frmCab').desabilitaCampo();";
	
	if (($cddopcao <> "I") && ($cddopcao <> "A")){
		echo "$('#dsmotest','#frmCab').desabilitaCampo();";		
		echo "$('#tpaplica','#frmCab').desabilitaCampo();";	
	}
	
	if ($cddopcao == "A"){
		echo "$('#dsmotest','#frmCab').habilitaCampo();";		
		echo "$('#tpaplica','#frmCab').habilitaCampo();";	
	}
	
	if ($cddopcao == "C"){
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "E"){
		echo "trocaBotao('Excluir');";
	}

	
	echo "$('#dsmotest','#frmCab').focus();";		
			
?>
