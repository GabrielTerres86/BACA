<? 
/*!
 * FONTE        : exporta_arq_cnae.php
 * CRIAÇÃO      : Tiago MAchado Flor         
 * DATA CRIAÇÃO : 25/10/2016 
 * OBJETIVO     : Rotina para exporta arq de cnaes
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
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$retornoAposErro = 'focaCampoErro(\'cdcnae\', \'frmCadastro\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>3</cdcooper>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<flgerlog>YES</flgerlog>'; 
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	$xmlResult = mensageria($xml, "COCNAE", 'EXPORTAR_ARQ_CNAE', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?> alert("<? echo $msgErro; ?>"); <?
		echo 'showError("error","Arquivo nao pode ser exportado.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
		exit();
	}
?>
	$('#spMensagem', '#frmExporta').html("<a style='text-decoration:none; color: black; font-weight: bold; width:100%' href='" + UrlSite + "telas/cocnae/download.php' target='blank'> <img src='" + UrlSite + "imagens/geral/ico_download.png' > Arquivo de CNAES Bloqueados Download</img> </a> ");
	$('#spMensagem', '#frmExporta').css("width","100%");
    $('#btContinuar').hide();	
