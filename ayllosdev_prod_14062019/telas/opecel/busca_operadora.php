<? 
/*!
 * FONTE        : busca_operadora.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 24/01/2017
 * OBJETIVO     : Rotina para buscar a operadora selecionada
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C'; 
	$cdoperadora = (isset($_POST['cdoperadora'])) ? $_POST['cdoperadora'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdoperadora>'.$cdoperadora.'</cdoperadora>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_OPECEL", "BUSCA_OPERADORA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',"$('#cdoperadora','#frmCab').focus();",false);
	}
	
	$nmoperadora = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$flgsituacao = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
	$cdhisdebcop = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
	$cdhisdebcnt = $xmlObjeto->roottag->tags[0]->tags[3]->cdata;
	$perreceita  = $xmlObjeto->roottag->tags[0]->tags[4]->cdata;
	$dshisdebcop = $xmlObjeto->roottag->tags[0]->tags[5]->cdata;
	$dshisdebcnt = $xmlObjeto->roottag->tags[0]->tags[6]->cdata;
	
	echo "$('#nmoperadora','#frmCab').val('$nmoperadora');";
	echo "$('#flgsituacao','#frmOpecel').val('$flgsituacao');";
	echo "$('#cdhisdebcop','#frmOpecel').val('$cdhisdebcop');";
	echo "$('#cdhisdebcnt','#frmOpecel').val('$cdhisdebcnt');";
	echo "$('#perreceita','#frmOpecel').val('$perreceita');";
	echo "$('#dshisdebcop','#frmOpecel').val('$dshisdebcop');";
	echo "$('#dshisdebcnt','#frmOpecel').val('$dshisdebcnt');";
	echo "liberaCampos();";
?>
