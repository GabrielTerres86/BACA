<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann / Tiago Machado Flor       
 * DATA CRIAÇÃO : 27/02/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADTIC
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
	$cdtipcat		= (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0  ; 
	$dstipcat		= (isset($_POST['dstipcat'])) ? $_POST['dstipcat'] : ''  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadtic';	  break;
		case 'I': $procedure = 'incluir-cadtic'; break;
		case 'A': $procedure = 'alterar-cadtic';   break;
		case 'E': $procedure = 'excluir-cadtic';    break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdtipcat\', \'frmCab\');';
	
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
	$xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';
	$xml .= '		<dstipcat>'.$dstipcat.'</dstipcat>';
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
	
	$dstipcat = $xmlObjeto->roottag->tags[0]->attributes["DSTIPCAT"];
	
	if ($cddopcao == "C"){
		echo "$('#dstipcat','#frmCab').val('$dstipcat');";
		echo "$('#cdtipcat','#frmCab').focus();";
		echo "trocaBotao( '' );";
		echo "$('#dstipcat','#frmCab').desabilitaCampo();";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Tipo de categoria incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Tipo de categoria alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Tipo de categoria excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

			
?>
