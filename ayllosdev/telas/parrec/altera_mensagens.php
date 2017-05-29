<? 
/*!
 * FONTE        : altera_mensagens.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 07/02/2017
 * OBJETIVO     : Rotina para alterar as mensagens da Opção "M"
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
	$dsmsgsaldo = (isset($_POST['dsmsgsaldo'])) ? $_POST['dsmsgsaldo'] : ' ' ; 
	$dsmsgoperac = (isset($_POST['dsmsgoperac'])) ? $_POST['dsmsgoperac'] : ' ' ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cddopcao>'. $cddopcao .'</cddopcao>';
	$xml .= '		<dsmsgsaldo>'. utf8_decode($dsmsgsaldo) .'</dsmsgsaldo>';
	$xml .= '		<dsmsgoperac>'. utf8_decode($dsmsgoperac) .'</dsmsgoperac>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "ALTERA_MENSAGENS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
