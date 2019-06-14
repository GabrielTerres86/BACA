<? 
/*!
 * FONTE        : manter_detalhamento.php
 * CRIAÇÃO      : Diego Simas         
 * DATA CRIAÇÃO : 01/05/2018
 * OBJETIVO     : Rotina para manter os detalhamentos da lista de regras da tela PARCDC.
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
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada

    $cddopdet =   (isset($_POST['cddopdet']))   ? $_POST['cddopdet']   : '';
    $cdfaixa =    (isset($_POST['cdfaixa']))    ? $_POST['cdfaixa']    : 0 ;
	$idcomissao = (isset($_POST['idcomissao'])) ? $_POST['idcomissao'] : 0 ;
	$vlinifvl =   (isset($_POST['vlinifvl']))   ? $_POST['vlinifvl']   : 0 ;
	$vlfinfvl =   (isset($_POST['vlfinfvl']))   ? $_POST['vlfinfvl']   : 0 ;
	$vlcomiss = (isset($_POST['vlcomiss'])) ? $_POST['vlcomiss'] : 0 ;
    //$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 

    $retornoAposErro = 'focaCampoErro(\'idcomissao\', \'frmComissao\');';
	
    //if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		//exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	//}

    // Monta o xml de requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <cddopdet>".$cddopdet."</cddopdet>";
    $xml .= "  <cdfaixa>".$cdfaixa."</cdfaixa>";
    $xml .= "  <idcomissao>".$idcomissao."</idcomissao>";
    $xml .= "  <vlinicial>".str_replace(',','.', $vlinifvl)."</vlinicial>";
    $xml .= "  <vlfinal>".str_replace(',','.', $vlfinfvl)."</vlfinal>";
    $xml .= "  <vlcomiss>".str_replace(',','.', $vlcomiss)."</vlcomiss>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_DETALHAMENTO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    $detalhe = $xmlObjeto->roottag->tags[0]->tags[0]->tags; 
    $idRetorno = getByTagName($detalhe, 'iddetcor');

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {			
        $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
        if ($msgErro == "") {
            $msgErro = utf8_decode($xmlObjeto->roottag->tags[0]->cdata);
        }            
        $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
                    
        exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
        exit();
    }else{
        if($cddopdet == "A"){
            echo 'showError("inform","Regra de Comiss&atilde;o alterada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';				
        }
        if($cddopdet == "I"){            
            echo "$('#cdfaixav','#frmDetalheComissao').val(".$idRetorno.");";
            echo 'showError("inform","Regra de comiss&atilde;o inclu&iacute;da com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';				            
            echo 'fechaRotina($(\'#divUsoGenerico\'));';
        }
        if($cddopdet == "E"){
            echo 'showError("inform","Regra de comiss&atilde;o exclu&iacute;da com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';				
        }
        exit();
    }
			
?>
