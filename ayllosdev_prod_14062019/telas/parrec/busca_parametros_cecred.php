<? 
/*!
 * FONTE        : busca_parametros_cecred.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 02/02/2017
 * OBJETIVO     : Rotina para buscar parametros de recarga de celular da CECRED
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "BUSCA_PARAM_CECRED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
	
	$nrispbif = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$cdbccxlt = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
	$nmresbcc = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
	$cdageban = $xmlObjeto->roottag->tags[0]->tags[3]->cdata;
	$nmageban = $xmlObjeto->roottag->tags[0]->tags[4]->cdata;
	$nrdconta = $xmlObjeto->roottag->tags[0]->tags[5]->cdata;
	$nrdocnpj = $xmlObjeto->roottag->tags[0]->tags[6]->cdata;
	$dsdonome = $xmlObjeto->roottag->tags[0]->tags[7]->cdata;
	
	echo "$('#nrispbif','#frmParrec').val('$nrispbif');";
	echo "$('#cdbccxlt','#frmParrec').val('$cdbccxlt');";
	echo "$('#nmresbcc','#frmParrec').val('$nmresbcc');";
	echo "$('#cdageban','#frmParrec').val('$cdageban');";
	echo "$('#nmageban','#frmParrec').val('$nmageban');";
	echo "$('#nrdconta','#frmParrec').val('$nrdconta');";
	echo "$('#nrdocnpj','#frmParrec').val('$nrdocnpj');";
	echo "$('#dsdonome','#frmParrec').val('$dsdonome');";
	echo "$('#divBotoes', '#divTela').css({'display':'block'});";
	echo "$('#btVoltar','#divBotoes').show();";
	echo "$('#frmParrec').css({'display':'block'});";	
	echo "formataLayoutCecred();";
	echo "$('#divCecred', '#frmParrec').css('display','block');";
	if ($cddopcao == 'A'){
		echo "$('#btProsseguir','#divBotoes').show();";
		echo "$('#nrispbif','#frmParrec').focus();";
	}else{
		echo "$('#btProsseguir','#divBotoes').hide();";
	}
	
?>
