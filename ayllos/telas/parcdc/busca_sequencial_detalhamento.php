<? 
/*!
 * FONTE        : busca_sequencial_detalhamento.php
 * CRIAÇÃO      : Diego Simas         
 * DATA CRIAÇÃO : 02/05/2018
 * OBJETIVO     : Rotina para buscar código sequencial da tabela de detalhamento PARCDC.
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
	
	$retornoAposErro = 'focaCampoErro(\'cdfaixav\', \'frmDetalheComissao\');';
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
    $idcomissao = (isset($_POST['idcomissao'])) ? $_POST['idcomissao'] : '' ; 
    $nmcomissao = (isset($_POST['nmcomissao'])) ? $_POST['nmcomissao'] : '' ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    // Monta o xml de requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PARCDC", "BUSCA_SEQ_DETALHAMENTO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
        $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
        if ($msgErro == "") {
            $msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->cdata);
        }
    
        $msgErro = str_replace('"','',str_replace('(','',str_replace(')','',$msgErro)));	
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
        exit();
    }else{
        $detalhamento = $xmlObjeto->roottag->tags[0]->tags[0]->tags;			
		$cdseqdetalhe = getByTagName($detalhamento, 'cdseqdetalhe');
        echo "$('#cdfaixav','#frmDetalheComissao').val(".$cdseqdetalhe.");";
        echo "$('#idcomissao','#frmDetalheComissao').val(glbTabidcomissao);";
	    echo "$('#nmcomissao','#frmDetalheComissao').val(glbTabnmcomissao);";
        echo "highlightObjFocus( $('#frmDetalheComissao') );";
	    echo "$('#vlinifvl','#frmDetalheComissao').focus();";
	    echo "bloqueiaFundo( $('#divRotina') );";
        exit();
    }	
			
?>
