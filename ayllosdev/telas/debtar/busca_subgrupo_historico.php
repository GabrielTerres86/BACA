<? 
/*!
 * FONTE        : busca_subgrupo_historico.php
 * CRIA��O      : Tiago Machado Flor         
 * DATA CRIA��O : 20/03/2015 
 * OBJETIVO     : Rotina para buscar subgrupo historico debtar
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
	$cdhistor		= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0; 
	$cdhisest       = (isset($_POST['cdhisest'])) ? $_POST['cdhisest'] : 0; 
	$flgestor		= (isset($_POST['flgestor'])) ? $_POST['flgestor'] : 0; 
	
	// Dependendo da opera��o, chamo uma procedure diferente
	if($flgestor == 1){
		$procedure = 'busca-subgrupo-historico-estorno';
	}else{
		$procedure = 'busca-subgrupo-historico';
	}
	
	if($cdhisest > 0){
		$cdhistor = $cdhisest;
	}	
	
	$retornoAposErro = 'focaCampoErro(\'cdhistor\', \'frmDebtar\');';
	
	$cddopcao = 'E';
	
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
	if($flgestor){		
		$xml .= '		<cdhisest>'.$cdhistor.'</cdhisest>';
	}else{
		$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';
	}	
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
	
	$cdsubgru = $xmlObjeto->roottag->tags[0]->attributes["CDSUBGRU"];
	
	echo "$('#cdsubgru','#frmDebtar').val('$cdsubgru');";	
	echo "$('#cdagenci','#frmDebtar').focus();";		
			
?>
