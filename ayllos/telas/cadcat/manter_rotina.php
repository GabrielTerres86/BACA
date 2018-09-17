<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 26/02/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADCAT
 * --------------
 * ALTERAÇÕES   : 20/08/2013 - Retirado parametro nrconven (Daniel).
 *				
 *				  25/02/2016 - Adição de novas flags (Dionathan).
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
	$cddgrupo		= (isset($_POST['cddgrupo'])) ? $_POST['cddgrupo'] : 0  ;
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdsubgru		= (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0  ;
	$dscatego		= (isset($_POST['dscatego'])) ? $_POST['dscatego'] : 0  ;
	$cdtipcat       = (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0  ;
	$cdcatego		= (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ;
	$fldesman		= (isset($_POST['fldesman'])) ? $_POST['fldesman'] : ''  ;
	$flrecipr		= (isset($_POST['flrecipr'])) ? $_POST['flrecipr'] : ''  ;
	$flcatcee		= (isset($_POST['flcatcee'])) ? $_POST['flcatcee'] : ''  ;
	$flcatcoo		= (isset($_POST['flcatcoo'])) ? $_POST['flcatcoo'] : ''  ;
	//$nrconven		= (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0  ;

	// Se NAO for Grupo 3 - Cobranca seta como NAO
    if ($cddgrupo != 3) {
        $fldesman = 0;
        $flrecipr = 0;
        $flcatcee = 0;
        $flcatcoo = 0;
    }
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'BUSCA_CADCAT';	break;
		case 'I': $procedure = 'INCLUI_CADCAT'; break;
		case 'A': $procedure = 'ALTERA_CADCAT'; break;
		case 'E': $procedure = 'EXCLUI_CADCAT'; break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cddgrupo\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= '		<cddgrupo>'.$cddgrupo.'</cddgrupo>';
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
	$xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';
	$xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
	$xml .= '		<dscatego>'.$dscatego.'</dscatego>';
	$xml .= '		<fldesman>'.$fldesman.'</fldesman>';
	$xml .= '		<flrecipr>'.$flrecipr.'</flrecipr>';
	$xml .= '		<flcatcee>'.$flcatcee.'</flcatcee>';
	$xml .= '		<flcatcoo>'.$flcatcoo.'</flcatcoo>';
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
	$fldesman = getByTagName($categoria->tags,'FLDESMAN');
	$flrecipr = getByTagName($categoria->tags,'FLRECIPR');
	$flcatcee = getByTagName($categoria->tags,'FLCATCEE');
	$flcatcoo = getByTagName($categoria->tags,'FLCATCOO');
	
	if ($cddopcao == "C"){
		echo "$('#dscatego','#frmCab').val('$dscatego');";
		echo "$('#fldesman','#frmCab').val('$fldesman');";
		echo "$('#flrecipr','#frmCab').val('$flrecipr');";
		echo "$('#flcatcee','#frmCab').val('$flcatcee');";
		echo "$('#flcatcoo','#frmCab').val('$flcatcoo');";
		echo "$('#cddgrupo','#frmCab').focus();";
		echo "$('#dscatego','#frmCab').desabilitaCampo();";
		echo "$('#cdsubgru','#frmCab').desabilitaCampo();";
		echo "$('#cdtipcat','#frmCab').desabilitaCampo();";
		echo "$('#cddgrupo','#frmCab').desabilitaCampo();";
		echo "$('#fldesman','#frmCab').desabilitaCampo();";
		echo "$('#flrecipr','#frmCab').desabilitaCampo();";
		echo "$('#flcatcee','#frmCab').desabilitaCampo();";
		echo "$('#flcatcoo','#frmCab').desabilitaCampo();";
		
		echo "trocaBotao('');";
	}
	
	if ($cddopcao == "I"){
		echo 'showError("inform","Categoria incluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Categoria alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "E"){
		echo 'showError("inform","Categoria excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}

			
?>