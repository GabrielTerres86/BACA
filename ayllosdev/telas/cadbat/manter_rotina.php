<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago MAchado Flor         
 * DATA CRIAÇÃO : 21/02/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADGRU
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
	$cdbattar		= (isset($_POST['cdbattar'])) ? $_POST['cdbattar'] : '' ; 
	$nmidenti		= (isset($_POST['nmidenti'])) ? $_POST['nmidenti'] : '' ; 	
	$tpcadast		= (isset($_POST['tpcadast'])) ? $_POST['tpcadast'] : 0 ; 	
	$cdprogra		= (isset($_POST['cdprogra'])) ? $_POST['cdprogra'] : '' ; 	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : '' ; 	
	$cdpartar		= (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : '' ; 	

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'buscar-cadbat';	  break;
		case 'I': $procedure = 'incluir-cadbat';  break;
		case 'A': $procedure = 'alterar-cadbat';  break;
		case 'E': $procedure = 'excluir-cadbat';  break;
		case 'V': $procedure = 'vincular-cadbat';  break;
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
	$xml .= '		<cdbattar>'.$cdbattar.'</cdbattar>';
	$xml .= '		<nmidenti>'.$nmidenti.'</nmidenti>';
	$xml .= '		<tpcadast>'.$tpcadast.'</tpcadast>';
	$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';
	$xml .= '		<cdpartar>'.$cdpartar.'</cdpartar>';
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
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Tarifa/Parametro incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Vinculo alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Vinculo excluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

	if ($cddopcao == "V"){
		echo 'showError("inform","Vinculado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
?>
