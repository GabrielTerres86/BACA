<? 
/*!
 * FONTE        : busca_agencia.php
 * CRIA��O      : Tiago         
 * DATA CRIA��O : 20/03/2015
 * OBJETIVO     : Rotina para buscar pac na tela debtar
 * --------------
 * ALTERA��ES   : 
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
	
	// Recebe a opera��o que est� sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdagetel		= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ; 
	$ccooptel		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ; 

	// Procedure a ser chamada
	$procedure = 'buscar-pac-reltar';
	
	$retornoAposErro = 'focaCampoErro(\'cdagenci\', \'frmDebtar\');';
	
	$cddopcao = 'E';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '       <ccooptel>'.$ccooptel.'</ccooptel>';
	$xml .= '       <cdagetel>'.$cdagetel.'</cdagetel>';
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
	
	$nmresage = $xmlObjeto->roottag->tags[0]->attributes["NMRESAGE"];
		
	echo "$('#nmresage','#frmDebtar').val('$nmresage');";
	echo "$('#cdagenci','#frmDebtar').desabilitaCampo();";
	echo "$('#inpessoa','#frmDebtar').focus();";	
?>
