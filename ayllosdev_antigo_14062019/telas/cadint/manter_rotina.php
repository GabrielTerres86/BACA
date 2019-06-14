<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago Flor       
 * DATA CRIAÇÃO : 05/03/2013
 * OBJETIVO     : Rotina para manter as operações da tela CADINT
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
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : 0  ; 
	$dsinctar		= (isset($_POST['dsinctar'])) ? $_POST['dsinctar'] : 0  ; 	
	$flgocorr		= (isset($_POST['flgocorr'])) ? $_POST['flgocorr'] : 'no' ; 	
	$flgmotiv		= (isset($_POST['flgmotiv'])) ? $_POST['flgmotiv'] : 'no'  ; 	
	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadint';	  break;
		case 'I': $procedure = 'incluir-cadint'; break;
		case 'A': $procedure = 'alterar-cadint';   break;
		case 'E': $procedure = 'excluir-cadint';    break;
	}
	
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
	$xml .= '		<dsinctar>'.$dsinctar.'</dsinctar>';
	$xml .= '		<flgocorr>'.$flgocorr.'</flgocorr>';
	$xml .= '		<flgmotiv>'.$flgmotiv.'</flgmotiv>';
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
	
	
	echo "$('#flgocorr','#frmCab').prop('checked',false);";	
	echo "$('#flgmotiv','#frmCab').prop('checked',false);";
	
	if ( $flgocorr == 'yes' ){	
		echo "$('#flgocorr','#frmCab').prop('checked',true);";
	}
	
	if ( $flgmotiv == 'yes' ){	
		echo "$('#flgmotiv','#frmCab').prop('checked',true);";
	}
	
	if ($cddopcao == "C"){
		echo "$('#dsinctar','#frmCab').val('$dsinctar');";	
		echo "$('#cdinctar','#frmCab').focus();";
		echo "trocaBotao('');";
		echo "$('#dsinctar','#frmCab').desabilitaCampo();";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Tipo de incidencia incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Tipo de incidencia alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Tipo de incidencia excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

			
?>
