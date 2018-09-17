<? 
/*!
 * FONTE        : busca_convenio.php
 * CRIAÇÃO      : Daniel Zimmermann       
 * DATA CRIAÇÃO : 01/08/2013 
 * OBJETIVO     : Rotina para buscar convenio
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para registros
 *							   de cobranca (Daniel).
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
	$nrconven		= (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0  ; 
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : 0  ; 
	$cdocorre		= (isset($_POST['cdocorre'])) ? $_POST['cdocorre'] : 0  ;
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : 0  ;	
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'buscar-convenio';
	
	$retornoAposErro = 'focaCampoErro(\'nrconven\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	$xml .= '		<cdcopatu>'.$cdcopatu.'</cdcopatu>';
	$xml .= '		<nrconven>'.$nrconven.'</nrconven>';
	$xml .= '		<cdocorre>'.$cdocorre.'</cdocorre>';
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
	
	$dsconven = $xmlObjeto->roottag->tags[0]->attributes["DSCONVEN"];	
	
	echo "$('#dsconven','#frmAtribuicaoDetalhamento').val('$dsconven');";
	echo "$('#dsconven','#frmAtribuicaoDetalhamento').desabilitaCampo();";
		
?>
