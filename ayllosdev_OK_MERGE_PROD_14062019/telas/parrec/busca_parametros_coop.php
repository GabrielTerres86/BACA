<? 
/*!
 * FONTE        : busca_parametros_singulares.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 24/01/2017
 * OBJETIVO     : Rotina para buscar parametros de recarga de celular das cooperativas singulares
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C' ; 
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcoppar>'.$cdcooper.'</cdcoppar>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "TELA_PARREC", "BUSCA_PARAM_COOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
	
	$flsitsac = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$flsittaa = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
	$flsitibn = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
	$vlrmaxpf = $xmlObjeto->roottag->tags[0]->tags[3]->cdata;
	$vlrmaxpj = $xmlObjeto->roottag->tags[0]->tags[4]->cdata;
	
	echo "checaRadio('flsitsac', $flsitsac);";
	echo "checaRadio('flsittaa', $flsittaa);";
	echo "checaRadio('flsitibn', $flsitibn);";
	echo "$('#vlrmaxpf','#frmParrec').val('$vlrmaxpf');";
	echo "$('#vlrmaxpj','#frmParrec').val('$vlrmaxpj');";
	echo "formataLayoutSingulares();";
	echo "$('#divBotoes', '#divTela').css({'display':'block'});";
	echo "$('#btVoltar','#divBotoes').show();";
	echo "$('#frmParrec').css({'display':'block'});";
	echo "$('#divSingulares', '#frmParrec').css({'display':'block'});";
	if ($cddopcao == 'A'){
		echo "$('#btProsseguir','#divBotoes').show();";
		echo "$('#vlrmaxpf','#frmParrec').select();";
	}else{
		echo "$('#btProsseguir','#divBotoes').hide();";
	}
	
?>
