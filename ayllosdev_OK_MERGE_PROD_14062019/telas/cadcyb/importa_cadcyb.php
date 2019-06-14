<? 
/*!
 * FONTE        : altera_cadcyb.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Rotina para alterar as informações da tela CADCYB
 * --------------
 * ALTERAÇÕES   : 12/09/2014 - Ajuste na verificação de permissão por tipo de operação (Jaison)
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

	// Recebe a operação que está sendo realizada
	$nmdarqui = (isset($_POST['nmdarqui'])) ? $_POST['nmdarqui'] : 0 ; 
	
	// Monta o xml dinâmico de acordo com a operação 
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
