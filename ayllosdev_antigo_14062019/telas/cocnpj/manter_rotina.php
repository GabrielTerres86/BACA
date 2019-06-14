<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago MAchado Flor         
 * DATA CRIAÇÃO : 26/09/2016 
 * OBJETIVO     : Rotina para manter as operações da tela COCNPJ
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
	$inpessoa       = (isset($_POST['nrcpfcgc'])) ? $_POST['inpessoa'] : '0'; 
	$nrcpfcgc  		= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '0' ; 
	$dsnome         = (isset($_POST['dsnome'])) ? $_POST['dsnome'] : '' ; 
	$dsmotivo		= (isset($_POST['dsmotivo'])) ? $_POST['dsmotivo'] : '' ; 		
	$dtarquivo      = (isset($_POST['dtarquivo'])) ? $_POST['dtarquivo'] : '' ; 	
	$tpinclusao		= '0'; //manual 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'BUSCA_CNPJ_BLOQUEADO';	  break;
		case 'I': $procedure = 'INSERIR_CNPJ_BLOQUEADO';  break;
		case 'E': $procedure = 'EXCLUIR_CNPJ_BLOQUEADO';  break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'nrcpfcgc\', \'frmCadastro\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<dsnome>'.utf8_decode( $dsnome ).'</dsnome>';
	$xml .= '		<dsmotivo>'.utf8_decode( $dsmotivo ).'</dsmotivo>';
	//$xml .= '		<dtarquivo> </dtarquivo>';
	$xml .= '		<tpinclusao>'.$tpinclusao.'</tpinclusao>';
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	$xmlResult = mensageria($xml, "COCNPJ", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","CNPJ incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","CNPJ excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
?>
