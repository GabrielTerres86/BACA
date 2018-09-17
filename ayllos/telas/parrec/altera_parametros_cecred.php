<? 
/*!
 * FONTE        : altera_parametros_cecred.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 02/02/2017
 * OBJETIVO     : Rotina para alterar os parametros de recarga de celular da CECRED
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
		
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'A' ; 
	$nrispbif = (isset($_POST['nrispbif'])) ? $_POST['nrispbif'] : ' ' ; 
	$cdageban = (isset($_POST['cdageban'])) ? $_POST['cdageban'] : '0' ; 
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '0' ; 
	$nrdocnpj = (isset($_POST['nrdocnpj'])) ? $_POST['nrdocnpj'] : '0' ; 
	$dsdonome = (isset($_POST['dsdonome'])) ? $_POST['dsdonome'] : ' ' ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrispbif>'. $nrispbif .'</nrispbif>';
	$xml .= '		<cdageban>'. $cdageban .'</cdageban>';
	$xml .= '		<nrdconta>'. $nrdconta .'</nrdconta>';
	$xml .= '		<nrdocnpj>'. $nrdocnpj .'</nrdocnpj>';
	$xml .= '		<dsdonome>'. utf8_decode($dsdonome) .'</dsdonome>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "ALTERA_PARAM_CECRED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
	}

	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','estadoInicial();',false);
?>
