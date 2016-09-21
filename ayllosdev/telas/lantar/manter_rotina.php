<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago Machado
 * DATA CRIAÇÃO : 26/03/2013
 * OBJETIVO     : Rotina para manter as operações da tela LANTAR
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
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$lstconta       = (isset($_POST['strNrdconta'])) ? $_POST['strNrdconta'] : '' ;	
	$lsthisto		= (isset($_POST['strCdhistor'])) ? $_POST['strCdhistor'] : ''  ;	
	$lstqtdla		= (isset($_POST['strQtlantar'])) ? $_POST['strQtlantar'] : '' ;
	$lsvlrtar		= (isset($_POST['strVltarifa'])) ? $_POST['strVltarifa'] : ''  ; 
	$lsqtdchq		= (isset($_POST['strQtdchcus'])) ? $_POST['strQtdchcus'] : ''  ; 
	$lsfvlcop		= (isset($_POST['strCdfvlcop'])) ? $_POST['strCdfvlcop'] : ''  ; 
	$inpessoa		= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0  ; 	
	$cddopcao		= 'I';

	
	// Procedure a ser executada
	$procedure = 'lancamento-manual-tarifa';
	
	$retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';		
	$xml .= '		<lstconta>'.$lstconta.'</lstconta>';
	$xml .= '		<lsthisto>'.$lsthisto.'</lsthisto>';
	$xml .= '		<lstqtdla>'.$lstqtdla.'</lstqtdla>';
	$xml .= '		<lsvlrtar>'.$lsvlrtar.'</lsvlrtar>';
	$xml .= '		<lsqtdchq>'.$lsqtdchq.'</lsqtdchq>';
	$xml .= '		<lsfvlcop>'.$lsfvlcop.'</lsfvlcop>';
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	echo 'showError("inform","Lan&ccedil;amentos efetuados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	
			
?>
