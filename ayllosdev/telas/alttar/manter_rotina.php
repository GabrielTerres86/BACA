<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 03/09/2015
 * OBJETIVO     : Rotina para manter as operações da tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 26/11/2015 - Ajustado para buscar os convenios de folha
 *                             de pagamento. (Andre Santos - SUPERO)
 *			      30/10/2017 - Adicionado os campos vlpertar, vlmaxtar, vlmintar 
 *							   e tpcobtar na tela. PRJ M150 (Mateus Z - Mouts)
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
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$dtdivulg		= (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : '' ;
	$dtvigenc		= (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : '' ;
	$lstvltar		= (isset($_POST['lstvltar'])) ? $_POST['lstvltar'] : '' ;
	$lstfaixa		= (isset($_POST['lstfaixa'])) ? $_POST['lstfaixa'] : '' ;
	$lstlcrem		= (isset($_POST['lstlcrem'])) ? $_POST['lstlcrem'] : '' ;
	$lstconve		= (isset($_POST['lstconve'])) ? $_POST['lstconve'] : '' ;
    $lstocorr		= (isset($_POST['lstocorr'])) ? $_POST['lstocorr'] : '' ;
    $cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : '' ;
	$vlpertar		= (isset($_POST['vlpertar'])) ? $_POST['vlpertar'] : '' ;
	$vlmintar		= (isset($_POST['vlmintar'])) ? $_POST['vlmintar'] : '' ;
    $vlmaxtar		= (isset($_POST['vlmaxtar'])) ? $_POST['vlmaxtar'] : '' ;
    $tpcobtar		= (isset($_POST['tpcobtar'])) ? $_POST['tpcobtar'] : '' ;
								
	// Procedure a ser executada
	$procedure = 'incluir-lista-cadfco';
	
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
	$xml .= '		<dtdivulg>'.$dtdivulg.'</dtdivulg>';
	$xml .= '		<dtvigenc>'.$dtvigenc.'</dtvigenc>';
	$xml .= '		<lstfaixa>'.$lstfaixa.'</lstfaixa>';	
	$xml .= '		<lstvltar>'.$lstvltar.'</lstvltar>';	
	$xml .= '		<lstconve>'.$lstconve.'</lstconve>';
	$xml .= '		<lstocorr>'.$lstocorr.'</lstocorr>';	
	$xml .= '		<lstlcrem>'.$lstlcrem.'</lstlcrem>';
	$xml .= '		<cdinctar>'.$cdinctar.'</cdinctar>';
	$xml .= '		<lsttptar>'.$tpcobtar.'</lsttptar>';
	$xml .= '		<lstvlper>'.$vlpertar.'</lstvlper>';
	$xml .= '		<lstvlmin>'.$vlmintar.'</lstvlmin>';
	$xml .= '		<lstvlmax>'.$vlmaxtar.'</lstvlmax>';
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	echo 'showError("inform","Tarifa(s) alterada(s) com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
?>
