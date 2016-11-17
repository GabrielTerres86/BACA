<? 
/*!
 * FONTE        : manter_rotina.php
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
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$dstarifa		= (isset($_POST['dstarifa'])) ? $_POST['dstarifa'] : '' ;
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ; 	
	$inpessoa		= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0  ; 	
	$cdocorre		= (isset($_POST['cdocorre'])) ? $_POST['cdocorre'] : 0  ; 	
	$cdmotivo		= (isset($_POST['cdmotivo'])) ? $_POST['cdmotivo'] : '0'; 
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : 0  ; 
	$cdsubgru		= (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0  ; 
	$flglaman		= (isset($_POST['flglaman'])) ? $_POST['flglaman'] : false;

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
	    case 'X': $procedure = 'buscar-cadtar';	 break;
		case 'C': $procedure = 'buscar-cadtar';	 break;
		case 'I': $procedure = 'incluir-cadtar'; break;
		case 'A': $procedure = 'alterar-cadtar'; break;
		case 'E': $procedure = 'excluir-cadtar'; break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cddgrupo\', \'frmCab\');';
	
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
	$xml .= '		<dstarifa>'.$dstarifa.'</dstarifa>';
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<cdocorre>'.$cdocorre.'</cdocorre>';
	$xml .= '		<cdmotivo>'.$cdmotivo.'</cdmotivo>';
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
	$xml .= '		<cdinctar>'.$cdinctar.'</cdinctar>';
	$xml .= '		<flglaman>'.$flglaman.'</flglaman>';
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
	
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];
	
	if ($cddopcao == "C"){
		echo "$('#dscatego','#frmCab').val('$dscatego');";
		echo "$('#cddgrupo','#frmCab').focus();";
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcad','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "X"){
		echo "$('#dscatego','#frmCab').val('$dscatego');";
		echo "$('#cddgrupo','#frmCab').focus();";
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcad','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Tarifa incluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));controlaCamposInclusao();");';				
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Tarifa alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Tarifa excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

			
?>
