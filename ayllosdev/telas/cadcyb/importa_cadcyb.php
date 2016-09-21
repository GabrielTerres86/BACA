<? 
/*!
 * FONTE        : altera_cadcyb.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Agosto/2013
 * OBJETIVO     : Rotina para alterar as informa��es da tela CADCYB
 * --------------
 * ALTERA��ES   : 12/09/2014 - Ajuste na verifica��o de permiss�o por tipo de opera��o (Jaison)
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'F')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	

	// Recebe a opera��o que est� sendo realizada
	$nmdarqui = (isset($_POST['nmdarqui'])) ? $_POST['nmdarqui'] : 0 ; 
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0170.p</Bo>';
	$xml .= '		<Proc>importa-dados-crapcyc</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '       <nmdarqui>'.$nmdarqui.'</nmdarqui>';
	$xml .= '       <dsdircop>'.$glbvars["dsdircop"].'</dsdircop>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
	} 
	
	echo 'showError("inform","Arquivo importado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
			
?>
