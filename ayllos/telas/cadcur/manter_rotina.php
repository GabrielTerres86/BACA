<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 19/06/2017
 * OBJETIVO     : Rotina para manter as operações da tela CADCUR
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
	$nmdeacao 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdfrmttl		= (isset($_POST['cdfrmttl'])) ? $_POST['cdfrmttl'] : 0  ; 
	$rsfrmttl		= (isset($_POST['rsfrmttl'])) ? $_POST['rsfrmttl'] : ''  ; 	
	$dsfrmttl		= (isset($_POST['dsfrmttl'])) ? $_POST['dsfrmttl'] : ''  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'I': $nmdeacao = 'INCLUI_CURSO'; break;
		case 'A': $nmdeacao = 'ALTERA_CURSO';   break;
		case 'E': $nmdeacao = 'EXCLUI_CURSO';    break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	if ($cddopcao != 'I'){
		$xml .= '		<cdfrmttl>'.$cdfrmttl.'</cdfrmttl>';
	}
	$xml .= '		<rsfrmttl>'.$rsfrmttl.'</rsfrmttl>';
	$xml .= '		<dsfrmttl>'.$dsfrmttl.'</dsfrmttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = mensageria($xml, "TELA_CADCUR", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	if ($cddopcao == "C"){
		$cdfrmttl = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
		$dsfrmttl = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
		$rsfrmttl = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
		echo "$('#cdfrmttl','#frmCadcur').val('$cdfrmttl');";
		echo "$('#dsfrmttl','#frmCadcur').val('$dsfrmttl');";
		echo "$('#rsfrmttl','#frmCadcur').val('$rsfrmttl');";
		echo "trocaBotao( '' );";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Curso inclu&iacute;do com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}elseif ($cddopcao == "A"){
		echo 'showError("inform","Curso alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}elseif ($cddopcao == "E"){
		echo 'showError("inform","Curso exclu&iacute;do com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
			
?>
