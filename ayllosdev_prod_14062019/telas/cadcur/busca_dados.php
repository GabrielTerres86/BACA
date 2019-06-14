<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 24/07/2017
 * OBJETIVO     : Rotina para buscar curso da tela CADCUR
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
	$cdfrmttl		= (isset($_POST['cdfrmttl'])) ? $_POST['cdfrmttl'] : 0  ; 
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0  ; 
	
	$retornoAposErro = 'focaCampoErro(\'cdfrmttl\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdfrmttl>'.$cdfrmttl.'</cdfrmttl>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = mensageria($xml, 'TELA_CADCUR', 'BUSCA_CURSO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$cdfrmttl = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$dsfrmttl = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
	$rsfrmttl = $xmlObjeto->roottag->tags[0]->tags[2]->cdata;
	echo "cTodosCabecalho.desabilitaCampo();";
	echo "formataLayout();";
	echo "$('#cdfrmttl','#frmCadcur').val('$cdfrmttl');";
	echo "$('#dsfrmttl','#frmCadcur').val('$dsfrmttl');";
	echo "$('#rsfrmttl','#frmCadcur').val('$rsfrmttl');";

	if ($cddopcao == 'A'){
		echo "trocaBotao( 'Alterar' );";
	}elseif ($cddopcao == 'E'){
		echo "trocaBotao( 'Excluir' );";		
	}else{
		echo "trocaBotao( '' );";		
	}
?>
