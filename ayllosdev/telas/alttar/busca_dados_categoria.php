<? 
/*!
 * FONTE        : busca_dados_categoria.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 04/03/2013 
 * OBJETIVO     : Rotina para buscar categoria na tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 27/04/2016 - Migração da procedure b1wgen0153.busca-cadcat para Oracle:
                               tela_cadcat.pc_busca_categoria (Dionathan)
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
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ;	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'BUSCA_CADCAT';
	
	$retornoAposErro = 'focaCampoErro(\'cdcatego\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "CADCAT", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$categoria = $xmlObj->roottag->tags[0]->tags[0];
	
	$dssubgru = getByTagName($categoria->tags,'DSSUBGRU');
	$dsdgrupo = getByTagName($categoria->tags,'DSDGRUPO');
	$dscatego = getByTagName($categoria->tags,'DSCATEGO');
	$cddgrupo = getByTagName($categoria->tags,'CDDGRUPO');
	$cdsubgru = getByTagName($categoria->tags,'CDSUBGRU');
	$cdtipcat = getByTagName($categoria->tags,'CDTIPCAT');
	
	if($dssubgru <> ''){
		echo "$('#dssubgru','#frmCab').val('$dssubgru');";
		echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
		echo "$('#dssubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	}
	
	if($dsdgrupo <> ''){
		echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
		echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
		echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	}
	
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	
	echo "$('#cdtipcat','#frmCab').val('$cdtipcat');";
	
	echo "$('#dscatego','#frmCab').desabilitaCampo();";
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

    echo "btnContinuar();";
?>
