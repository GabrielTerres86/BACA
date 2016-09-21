<? 
/*!
 * FONTE        : valida_replicacao.php
 * CRIAÇÃO      : Tiago Machado 
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para validar a replicacao da crapfco
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para replicacao registros
 *							   de cobranca (Daniel).
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
	$cdfvlcop		= (isset($_POST['cdfvlcop'])) ? $_POST['cdfvlcop'] : 0  ;	
	$cddopfco       = (isset($_POST['cddopfco'])) ? $_POST['cddopfco'] : '' ;	
	$cdfaixav		= (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0  ;	
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : 0  ;	
	$dtdivulg		= (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : 0  ;	
	$dtvigenc		= (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : 0  ;	
	$vltarifa		= (isset($_POST['vltarifa'])) ? $_POST['vltarifa'] : 0  ;	
	$vlrepass		= (isset($_POST['vlrepass'])) ? $_POST['vlrepass'] : 0  ;	
	
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
	$lstcdfvl		= (isset($_POST['lstcdfvl'])) ? $_POST['lstcdfvl'] : '' ;	
	$lstcdcop		= (isset($_POST['lstcdcop'])) ? $_POST['lstcdcop'] : '' ;	
	$lstdtdiv		= (isset($_POST['lstdtdiv'])) ? $_POST['lstdtdiv'] : '' ;	
	$lstdtvig		= (isset($_POST['lstdtvig'])) ? $_POST['lstdtvig'] : '' ;	
	$lstvltar		= (isset($_POST['lstvltar'])) ? $_POST['lstvltar'] : '' ;	
	$lstvlrep		= (isset($_POST['lstvlrep'])) ? $_POST['lstvlrep'] : '' ;	
	
	$lstconve		= (isset($_POST['lstconve'])) ? $_POST['lstconve'] : '' ;

	$lstlcrem		= (isset($_POST['lstlcrem'])) ? $_POST['lstlcrem'] : '' ;	
	$cdtipcat		= (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0 ; 

	$procedure = 'valida-replicacao';
	
	if ($cdtipcat == 2 ) { /* 2 - Convenio */
		$procedure = 'valida-replicacao-cob';
	}
	
	if ($cdtipcat == 3 ) { /* 3 - Credito */
		$procedure = 'valida-replicacao-credito';
	}
	
	$retornoAposErro = 'focaCampoErro(\'cdcooper\', \'frmAtribuicaoDetalhamento\');bloqueiaFundo($(\'#divRotina\'));';
	
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
	$xml .= '		<cdfvlcop>'.$cdfvlcop.'</cdfvlcop>';
	$xml .= '		<cddopfco>'.$cddopfco.'</cddopfco>';
	$xml .= '		<cdfaixav>'.$cdfaixav.'</cdfaixav>';
	$xml .= '		<cdcopatu>'.$cdcopatu.'</cdcopatu>';
	$xml .= '		<dtdivulg>'.$dtdivulg.'</dtdivulg>';
	$xml .= '		<dtvigenc>'.$dtvigenc.'</dtvigenc>';
	$xml .= '		<vltarifa>'.$vltarifa.'</vltarifa>';
	$xml .= '		<vlrepass>'.$vlrepass.'</vlrepass>';		
	$xml .= '		<lstcdcop>'.$lstcdcop.'</lstcdcop>';	
	$xml .= '		<lstdtdiv>'.$lstdtdiv.'</lstdtdiv>';	
	$xml .= '		<lstdtvig>'.$lstdtvig.'</lstdtvig>';	
	$xml .= '		<lstvltar>'.$lstvltar.'</lstvltar>';	
	$xml .= '		<lstvlrep>'.$lstvlrep.'</lstvlrep>';		
	$xml .= '		<lstconve>'.$lstconve.'</lstconve>';
	$xml .= '		<lstlcrem>'.$lstlcrem.'</lstlcrem>';
	$xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';
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
		
	echo 'realizaOpFco(\'R\');';
			
?>
