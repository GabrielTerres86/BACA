<? 
/*!
 * FONTE        : busca_mensagens.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/02/2017
 * OBJETIVO     : Rotina para buscar mensagens de recarga de celular
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'M' ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "BUSCA_MENSAGENS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
	
	$dsmsgsaldo = preg_replace('/\r\n|\r|\n/','\n',$xmlObjeto->roottag->tags[0]->tags[0]->cdata);
	$dsmsgoperac = preg_replace('/\r\n|\r|\n/','\n',$xmlObjeto->roottag->tags[0]->tags[1]->cdata);
	
	echo "$('#dsmsgsaldo','#frmParrec').val('$dsmsgsaldo');";
	echo "$('#dsmsgoperac','#frmParrec').val('$dsmsgoperac');";
	echo "formataLayoutSingulares();";
	echo "formataLayoutMensagens();";
	echo "$('#frmParrec').css('display', 'block');";
	echo "$('#divMensagens', '#frmParrec').css('display', 'block');";
	echo "$('#divBotoes', '#divTela').css({'display':'block'});";
	echo "$('#btVoltar','#divBotoes').show();";
	echo "$('#btProsseguir','#divBotoes').show();";
	echo "$('#dsmsgsaldo','#frmParrec').focus();";
?>
