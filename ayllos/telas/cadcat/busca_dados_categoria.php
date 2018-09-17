<? 
/*!
 * FONTE        : busca_dados_categoria.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 04/03/2013 
 * OBJETIVO     : Rotina para buscar CADCAT
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
	// Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
    }
	
	$categoria = $xmlObj->roottag->tags[0]->tags[0];
	
	$dscatego = getByTagName($categoria->tags,'DSCATEGO');
	$cdsubgru = getByTagName($categoria->tags,'CDSUBGRU');
	$dsdgrupo = getByTagName($categoria->tags,'DSDGRUPO');
	$dssubgru = getByTagName($categoria->tags,'DSSUBGRU');
	$cddgrupo = getByTagName($categoria->tags,'CDDGRUPO');
	$cdtipcat = getByTagName($categoria->tags,'CDTIPCAT');
	$dstipcat = getByTagName($categoria->tags,'DSTIPCAT');
	$fldesman = getByTagName($categoria->tags,'FLDESMAN');
	$flrecipr = getByTagName($categoria->tags,'FLRECIPR');
	$flcatcee = getByTagName($categoria->tags,'FLCATCEE');
	$flcatcoo = getByTagName($categoria->tags,'FLCATCOO');
	
	if ( $cddgrupo == 0 ) {
		$cddgrupo = '';
	}
		
	if ( $cdsubgru == 0 ) {
		$cdsubgru = '';	
	}
	
	echo "$('#cdsubgru','#frmCab').val('$cdsubgru');";
	echo "$('#dscatego','#frmCab').val('$dscatego');";
	echo "$('#cdtipcat','#frmCab').val('$cdtipcat');";
	echo "$('#dstipcat','#frmCab').val('$dstipcat');";
	echo "$('#dssubgru','#frmCab').val('$dssubgru');";
	echo "$('#dsdgrupo','#frmCab').val('$dsdgrupo');";
	echo "$('#cddgrupo','#frmCab').val('$cddgrupo');";
	echo "$('#fldesman','#frmCab').val('$fldesman');";
	echo "$('#flrecipr','#frmCab').val('$flrecipr');";
	echo "$('#flcatcee','#frmCab').val('$flcatcee');";
	echo "$('#flcatcoo','#frmCab').val('$flcatcoo');";
	
	echo "$('#dscatego','#frmCab').desabilitaCampo();";
	echo "$('#cdcatego','#frmCab').desabilitaCampo();";
	echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
	echo "$('#dsdgrupo','#frmCab').desabilitaCampo();";
	echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
	echo "$('#dssubgru','#frmCab').desabilitaCampo();";
	echo "$('#cdtipcat','#frmCab').desabilitaCampo();";
	echo "$('#dstipcat','#frmCab').desabilitaCampo();";
	echo "$('#fldesman','#frmCab').desabilitaCampo();";
	echo "$('#flrecipr','#frmCab').desabilitaCampo();";
	echo "$('#flcatcee','#frmCab').desabilitaCampo();";
	echo "$('#flcatcoo','#frmCab').desabilitaCampo();";
	
	echo "cTodasFlags.css({'display':'" . ($cddgrupo == 3 ? 'table-row' : 'none') . "'});";
	
	switch ($cddopcao)
	{
		case 'A':
			echo "trocaBotao('Alterar');";
			echo "liberaCamposEditaveis();";
			break;
		case 'E':
			echo "trocaBotao('Excluir');";
			break;
		case 'C':
			echo "trocaBotao('');";
			break;
	}
			
?>
