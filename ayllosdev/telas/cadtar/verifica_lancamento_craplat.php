<? 
/*!
 * FONTE        : verifica_lancamento_craplat.php
 * CRIA��O      : Tiago Machado Flor         
 * DATA CRIA��O : 30/04/2013 
 * OBJETIVO     : Rotina para buscar lancamento na craplat
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
	$cdhistor		= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0  ; 
	
	// Dependendo da opera��o, chamo uma procedure diferente
	$procedure = 'verifica-lanc-lat';
	
	$retornoAposErro = 'focaCampoErro(\'cdhistor\', \'frmDetalhaTarifa\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	if(($cddopcao != 'C') && ($cddopcao != 'X') && ($cddopcao != 'I')){
		//----------------------------------------------------------------------------------------------------------------------------------	
		// Controle de Erros
		//----------------------------------------------------------------------------------------------------------------------------------
		if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
			$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		}
	
	}
	echo "realizaOpDetalhamento('$cddopcao');";
?>
