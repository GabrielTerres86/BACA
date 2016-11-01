<? 
/*!
 * FONTE        : busca_dados_parametro.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para buscar dados categoria tela CADPAR
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
	$procedure 		= 'buscar-cooperativa';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdcopatu		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ; 
	
	$retornoAposErro = 'focaCampoErro(\'cdcooper\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	
	$nmrescop = $xmlObjeto->roottag->tags[0]->attributes["NMRESCOP"];	
	
	//echo "$('#cdcooper','#frmAtribuicaoDetalhamento').desabilitaCampo();";
	echo "$('#nmrescop','#frmAtribuicaoDetalhamento').val('$nmrescop');";
		
	echo "$('#dtdivulg','#frmAtribuicaoDetalhamento').focus();";
			
?>
