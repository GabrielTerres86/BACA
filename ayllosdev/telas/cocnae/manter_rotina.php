<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago MAchado Flor         
 * DATA CRIAÇÃO : 25/10/2016
 * OBJETIVO     : Rotina para manter as operações da tela COCNAE
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
	$cdcnae  		= (isset($_POST['cdcnae'])) ? $_POST['cdcnae'] : '0' ; 
	$dsmotivo		= (isset($_POST['dsmotivo'])) ? $_POST['dsmotivo'] : '' ; 		
	$dtarquivo      = (isset($_POST['dtarquivo'])) ? $_POST['dtarquivo'] : '' ; 	
	$tpbloqueio		= (isset($_POST['tpcnae'])) ? $_POST['tpcnae'] : '0' ; 	
	$tpinclusao		= '0'; //manual 	
	$dslicenca		= (isset($_POST['dslicenca'])) ? $_POST['dslicenca'] : '' ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'BUSCA_CNAE_BLOQUEADO';	  break;
		case 'I': $procedure = 'INSERIR_CNAE_BLOQUEADO';  break;
		case 'E': $procedure = 'EXCLUIR_CNAE_BLOQUEADO';  break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdcnae\', \'frmCadastro\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdcnae>'.$cdcnae.'</cdcnae>';
	$xml .= '		<dsmotivo>'.utf8_decode( $dsmotivo ).'</dsmotivo>';
	//$xml .= '		<dtarquivo> </dtarquivo>';
	$xml .= '		<tpbloqueio>'.$tpbloqueio.'</tpbloqueio>';
	$xml .= '		<tpinclusao>'.$tpinclusao.'</tpinclusao>';
	$xml .= '		<dslicenca>'.utf8_decode( $dslicenca ).'</dslicenca>';
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	$xmlResult = mensageria($xml, "COCNAE", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","CNAE incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","CNAE excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
?>
