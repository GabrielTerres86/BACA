<? 
/*!
 * FONTE        : manter_rotina_vinculo.php
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
	$cdpartar       = (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0 ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$cdopcao		= (isset($_POST['cdopcao'])) ? $_POST['cdopcao'] : '' ;
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 

	// Dependendo da operação, chamo uma procedure diferente
	switch($cdopcao) {
		case 'V': $procedure = 'vincula-parametro-tarifa';	 break;
		case 'D': $procedure = 'desvincula-parametro-tarifa'; break;
	}
	
	$retornoAposErro = '$(\'#cdpartar\',\'#frmVinculacaoParametro\').habilitaCampo();focaCampoErro(\'cdpartar\', \'frmVinculacaoParametro\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';
	$xml .= '		<cdpartar>'.$cdpartar.'</cdpartar>';
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
	
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];
	
		
	if ($cdopcao == "V"){
		echo 'showError("inform","Parametro vinculado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaDivRotina()");';				
	}
	
	if ($cdopcao == "D"){
		echo 'showError("inform","Parametro desvinculado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));return false;");';		
	}
	
			
?>
