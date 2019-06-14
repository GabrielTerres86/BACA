<? 
/*!
 * FONTE        : busca_agencia.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 20/03/2013 
 * OBJETIVO     : Rotina para buscar pac na tela RELTAR
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
	$cdagetel		= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ; 
	$ccooptel		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ; 

	// Procedure a ser chamada
	$procedure = 'buscar-pac-reltar';
	
	$retornoAposErro = 'focaCampoErro(\'cdagenci\', \'frmReltar\');';
	
	$cddopcao = 'C';
	
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
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$nmresage = $xmlObjeto->roottag->tags[0]->attributes["NMRESAGE"];
		
	echo "$('#nmresage','#frmReltar').val('$nmresage');";
	echo "$('#cdagenci','#frmReltar').desabilitaCampo();";
	echo "$('#inpessoa','#frmReltar').focus();";	
?>
