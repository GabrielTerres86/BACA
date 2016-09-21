<? 
/*!
 * FONTE        : manter_rotina_detalhamento.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 08/12/2015
 * OBJETIVO     : Rotina para manter as operações da tela FAIRRF
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
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$cddopcao          = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cddopdet          = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : '';
	$cdfaixa           = (isset($_POST['cdfaixa'])) ? $_POST['cdfaixa'] : 0;
	$inpessoa          = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;
	$vlfaixa_inicial   = (isset($_POST['vlfaixa_inicial'])) ? converteFloat($_POST['vlfaixa_inicial']) : 0;
	$vlfaixa_final     = (isset($_POST['vlfaixa_final'])) ? converteFloat($_POST['vlfaixa_final']) : 0;
	$vlpercentual_irrf = (isset($_POST['vlpercentual_irrf'])) ? converteFloat($_POST['vlpercentual_irrf']) : 0;
	$vldeducao         = (isset($_POST['vldeducao'])) ? converteFloat($_POST['vldeducao']) : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cddopdet>".$cddopdet."</cddopdet>";
	$xml .= "   <cdfaixa>".$cdfaixa."</cdfaixa>";
	$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "   <vlfaixa_inicial>".$vlfaixa_inicial."</vlfaixa_inicial>";
	$xml .= "   <vlfaixa_final>".$vlfaixa_final."</vlfaixa_final>";
	$xml .= "   <vlpercentual_irrf>".$vlpercentual_irrf."</vlpercentual_irrf>";
	$xml .= "   <vldeducao>".$vldeducao."</vldeducao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	//exibirErro('error', $xml, 'Alerta - Ayllos', '', false);exit();
	
	// Dependendo da operação, chamo uma ação diferente
	switch($cddopdet) {
		case 'I': $nmdeacao = 'MANTEM_FAIXA_IRRF'; break;
		case 'A': $nmdeacao = 'MANTEM_FAIXA_IRRF'; break;
		case 'E': $nmdeacao = 'EXCLUI_FAIXA_IRRF'; break;
	}
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "FAIRRF", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	/*echo "<pre>";
	var_dump($xmlObj);
	echo "</pre>";
	return;*/
	
    // Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[1]->cdata;
    }
	
	if ($cddopdet == "I"){
		echo "$('#vlfaixa_inicial','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vlfaixa_final','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vlpercentual_irrf','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vldeducao','#frmDetalhaFaixa').desabilitaCampo();";
		echo 'showError("inform","Faixa incluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divRotina\'));carregaDetalhamento();");';
	}
	
	if ($cddopdet == "A"){
		echo "$('#vlfaixa_inicial','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vlfaixa_final','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vlpercentual_irrf','#frmDetalhaFaixa').desabilitaCampo();";
		echo "$('#vldeducao','#frmDetalhaFaixa').desabilitaCampo();";
		echo 'showError("inform","Faixa alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","hideMsgAguardo(); blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));fechaRotina($(\'#divRotina\'));carregaDetalhamento();");';	
	}
	
	if ($cddopdet == "E"){
		echo 'showError("inform","Faixa excluida com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));carregaDetalhamento();");';		
	}
			
?>
