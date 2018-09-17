<? 
/*!
 * FONTE        : altera_operadora.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 26/01/2017
 * OBJETIVO     : Rotina para alterar a operadora selecionada
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
	$cdoperadora = (isset($_POST['cdoperadora'])) ? $_POST['cdoperadora'] : 0 ; 
	$flgsituacao = (isset($_POST['flgsituacao'])) ? $_POST['flgsituacao'] : 0 ; 
	$cdhisdebcop = (isset($_POST['cdhisdebcop'])) ? $_POST['cdhisdebcop'] : 0 ; 
	$cdhisdebcnt = (isset($_POST['cdhisdebcnt'])) ? $_POST['cdhisdebcnt'] : 0 ; 
	$perreceita  = (isset($_POST['perreceita']))  ? $_POST['perreceita'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdoperadora>'.$cdoperadora.'</cdoperadora>';
	$xml .= '       <flgsituacao>'.$flgsituacao.'</flgsituacao>';
	$xml .= '       <cdhisdebcop>'.$cdhisdebcop.'</cdhisdebcop>';
	$xml .= '       <cdhisdebcnt>'.$cdhisdebcnt.'</cdhisdebcnt>';
	$xml .= '       <perreceita>' .$perreceita .'</perreceita>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_OPECEL", "ALTERA_OPERADORA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','estadoInicial();',false);
?>
