<? 
/*!
 * FONTE        : busca_dados_tarifa.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Rotina para buscar dados da tarifa na tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 26/11/2015 - Ajustado para buscar os convenios de folha
 *                             de pagamento. (Andre Santos - SUPERO) 
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
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;	
	$procedure      = 'buscar-cadtar';
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
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
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';
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
	
	$cddgrupo = $xmlObjeto->roottag->tags[0]->attributes["CDDGRUPO"];
	$dsdgrupo = $xmlObjeto->roottag->tags[0]->attributes["DSDGRUPO"];
	$cdsubgru = $xmlObjeto->roottag->tags[0]->attributes["CDSUBGRU"];
	$dssubgru = $xmlObjeto->roottag->tags[0]->attributes["DSSUBGRU"];
	$cdcatego = $xmlObjeto->roottag->tags[0]->attributes["CDCATEGO"];
	$dscatego = $xmlObjeto->roottag->tags[0]->attributes["DSCATEGO"];	
	$dstarifa = $xmlObjeto->roottag->tags[0]->attributes["DSTARIFA"];
	$cdinctar = $xmlObjeto->roottag->tags[0]->attributes["CDINCTAR"];

	echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
	echo "$('#dssubgru','#frmCab').val('$dssubgru');";
	echo "$('#cdcatego','#frmCab').val('$cdcatego');";
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	echo "$('#dstarifa','#frmCab').val('$dstarifa');";
	echo "$('#cdinctar','#frmCab').val('$cdinctar');";
    
    echo "$('#cdtarifa','#frmCab').desabilitaCampo();";
    echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
    echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
    echo "$('#cdcatego','#frmCab').desabilitaCampo();";


    if ($cdcatego == 2) { // Cobranca
        echo "$('#linCobranca','#frmCab').show();";
        echo "$('#nrconven','#frmCab').habilitaCampo().focus();";
    } elseif ($cdcatego == 3) { // Emprestimo
        echo "$('#linEmprestimo','#frmCab').show();";
        echo "$('#cdlcremp','#frmCab').habilitaCampo().focus();";
    } else {
        echo "$('#dtdivulg','#frmCab').habilitaCampo().focus();";
    }
?>
