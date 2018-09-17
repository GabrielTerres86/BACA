<? 
/*!
 * FONTE        : busca_incidencia.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 07/03/2013
 * OBJETIVO     : Rotina para buscar dados da CRAPINT
 * --------------
 * ALTERAÇÕES   : 20/08/2013 - Incluso tratamento para ocultar campos ocorrencia
 *							   e motivo (Daniel).	
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
	$procedure 		= 'buscar-cadint';
	$retornoAposErro= '';
	
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : '0' ; 
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	$retornoAposErro = 'focaCampoErro(\'cdinctar\', \'frmCab\');';
	
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
	$xml .= '		<cdinctar>'.$cdinctar.'</cdinctar>';	
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
	
	$dsinctar = $xmlObjeto->roottag->tags[0]->attributes["DSINCTAR"];
	$flgocorr = $xmlObjeto->roottag->tags[0]->attributes["FLGOCORR"];
	$flgmotiv = $xmlObjeto->roottag->tags[0]->attributes["FLGMOTIV"];
	$fococorr = false;
	$focmotiv = false;	
		
	echo "$('#cdocorre','#frmCab').desabilitaCampo();";
	echo "$('#cdmotivo','#frmCab').desabilitaCampo();";	
	
	if( $flgocorr == "yes" ){
		echo "$('#cdocorre','#frmCab').habilitaCampo();";
		$fococorr = true;
	}
	
	if( $flgmotiv == "yes" ){
		echo "$('#cdmotivo','#frmCab').habilitaCampo();";
		$focmotiv = true;
	}
	
	if ( ( $fococorr == true ) || ( $flgmotiv == "yes" ) ) {
		echo "$('#divOcorrenciaMotivo').css({'display':'block'});";
	}
		
	echo "$('#cdtarifa','#frmCab').desabilitaCampo();";
	
	if( $fococorr == true ){
		echo "$('#cdocorre','#frmCab').focus();";		
	}else{
		if( $focmotiv == true ){
			echo "$('#cdmotivo','#frmCab').focus();";
		}
	}
	
?>
