<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 08/03/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADMET
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
	$cdmotest		= (isset($_POST['cdmotest'])) ? $_POST['cdmotest'] : 0  ; 
	$dsmotest		= (isset($_POST['dsmotest'])) ? $_POST['dsmotest'] : ''  ; 	
	$tpaplica		= (isset($_POST['tpaplica'])) ? $_POST['tpaplica'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadmet';	 break;
		case 'I': $procedure = 'incluir-cadmet'; break;
		case 'A': $procedure = 'alterar-cadmet'; break;
		case 'E': $procedure = 'excluir-cadmet'; break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdmotest\', \'frmCab\');';
	
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
	$xml .= '		<cdmotest>'.$cdmotest.'</cdmotest>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<dsmotest>'.$dsmotest.'</dsmotest>';
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
	
	$tpaplica = $xmlObjeto->roottag->tags[0]->attributes["TPAPLICA"];
	$dsmotest = $xmlObjeto->roottag->tags[0]->attributes["DSMOTEST"];	
	
	if ($cddopcao == "C"){
		echo "$('#tpaplica','#frmCab').val('$tpaplica');";
		echo "$('#dsmotest','#frmCab').val('$dsmotest');";
		echo "$('#tpaplica','#frmCab').desabilitaCampo();";
		echo "$('#dsmotest','#frmCab').desabilitaCampo();";
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Motivo incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Motivo alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Motivo excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

			
?>
