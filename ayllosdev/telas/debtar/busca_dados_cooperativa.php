<? 
/*!
 * FONTE        : busca_dados_parametro.php
 * CRIAÇÃO      : Tiago         
 * DATA CRIAÇÃO : 20/03/2015
 * OBJETIVO     : Rotina para buscar dados categoria tela DEBTAR
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
	
	$cddopcao = 'E';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
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
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}
	
	$nmrescop = $xmlObjeto->roottag->tags[0]->attributes["NMRESCOP"];	
	
	echo "$('#cdagenci','#frmDebtar').habilitaCampo();";
	echo "$('#nrdconta','#frmDebtar').habilitaCampo();";				
	echo "$('#cdcopaux','#frmDebtar').desabilitaCampo();";				
	
	
	echo "$('#nmrescop','#frmDebtar').val('$nmrescop');";
	
	
	if ($glbvars['cdcooper'] == 3) {
		echo "$('#cdagenci','#frmDebtar').focus();";		
	}else{
		echo "$('#cddgrupo','#frmDebtar').focus();";
	}
			
?>
