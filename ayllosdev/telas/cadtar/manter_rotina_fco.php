<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para manter as operações da tela CADTAR
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para registros
 *							   de cobranca (Daniel).
 *				  22/08/2013 - Incluso novo parametro cdlcremp (Daniel).	
 
				  20/11/2015 - Ajustando mensagem de sucesso para que seja
				               exibida corretamente (Andre Santos - SUPERO)
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
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdfvlcop		= (isset($_POST['cdfvlcop'])) ? $_POST['cdfvlcop'] : 0  ;	
	$cddopfco       = (isset($_POST['cddopfco'])) ? $_POST['cddopfco'] : '' ;	
	$cdfaixav		= (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0  ;	
	$cdcopatu		= (isset($_POST['cdcopatu'])) ? $_POST['cdcopatu'] : 0  ;	
	$dtdivulg		= (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : 0  ;	
	$dtvigenc		= (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : 0  ;	
	$vltarifa		= (isset($_POST['vltarifa'])) ? $_POST['vltarifa'] : 0  ;	
	$vlrepass		= (isset($_POST['vlrepass'])) ? $_POST['vlrepass'] : 0  ;	
	
	$lstcdfvl		= (isset($_POST['lstcdfvl'])) ? $_POST['lstcdfvl'] : '' ;	
	$lstcdcop		= (isset($_POST['lstcdcop'])) ? $_POST['lstcdcop'] : '' ;	
	$lstdtdiv		= (isset($_POST['lstdtdiv'])) ? $_POST['lstdtdiv'] : '' ;	
	$lstdtvig		= (isset($_POST['lstdtvig'])) ? $_POST['lstdtvig'] : '' ;	
	$lstvltar		= (isset($_POST['lstvltar'])) ? $_POST['lstvltar'] : '' ;	
	$lstvlrep		= (isset($_POST['lstvlrep'])) ? $_POST['lstvlrep'] : '' ;	
	
	$nrconven		= (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0  ;	
	
	$lstconve		= (isset($_POST['lstconve'])) ? $_POST['lstconve'] : '' ;	
	
	$cdocorre 		= (isset($_POST['cdocorre'])) ? $_POST['cdocorre'] : 0  ;

	$cdlcremp 		= (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : 0  ;	/* Daniel */
	$lstlcrem		= (isset($_POST['lstlcrem'])) ? $_POST['lstlcrem'] : '' ;	
	$cdinctar		= (isset($_POST['cdinctar'])) ? $_POST['cdinctar'] : '' ;
								
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopfco) {
		case 'C': $procedure = 'buscar-cadfco';	 break;
		case 'I': $procedure = 'incluir-cadfco'; break;
		case 'A': $procedure = 'alterar-cadfco'; break;
		case 'E': $procedure = 'excluir-cadfco'; break;
		case 'R': $procedure = 'replicar-cadfco'; break;
		case 'IR': $procedure = 'incluir-cadfco'; break;
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
	$xml .= '		<nrconven>'.$nrconven.'</nrconven>';	
	$xml .= '		<lstconve>'.$lstconve.'</lstconve>';
	$xml .= '		<cdocorre>'.$cdocorre.'</cdocorre>';
	$xml .= '		<cdlcremp>'.$cdlcremp.'</cdlcremp>';
	$xml .= '		<lstlcrem>'.$lstlcrem.'</lstlcrem>';
	$xml .= '		<cdinctar>'.$cdinctar.'</cdinctar>';
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
	
	if ($cddopfco == "C"){
	}
	
	if ($cddopfco == "I"){
		echo 'showError("inform","Atribui&ccedil;&atilde;o Detalhamento incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicialAtribDet();");';				
	}
	
	if ($cddopfco == "IR"){
		echo 'showError("inform","Atribui&ccedil;&atilde;o Detalhamento incluido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';				
	}
	
	if ($cddopfco == "A"){
		echo 'showError("inform","Atribui&ccedil;&atilde;o Detalhamento alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicialAtribDet();");';		
	}
	
	if ($cddopfco == "R"){
		echo 'showError("inform","Replica&ccedil;&atilde;o Detalhamento efetuada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicialAtribDet();");';		
	}
	
	if ($cddopfco == "E"){
		echo 'showError("inform","Atribui&ccedil;&atilde;o Detalhamento excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));recargaFco();");';		
	}

			
?>
