<? 
/*!
 * FONTE        : busca_sequencial.php 
 * CRIAÇÃO      : Diego Simas         
 * DATA CRIAÇÃO : 27/04/2018
 * OBJETIVO     : Rotina para buscar sequencial da tabela TBEPR_CDC_PARM_COMISSAO
 *                (Cadastro de Comissões)
 *                Tela -> PARCDC 
 *                Aba  -> Comissão
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

    // Monta o xml de requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PARCDC", "BUSCA_SEQ_COMISSAO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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

        $comissao = $xmlObjeto->roottag->tags[0]->tags[0]->tags;			
		$cdseqcomissao = getByTagName($comissao, 'cdseqcomissao');
		$dtcriacao = getByTagName($comissao, 'dtcriacao');

        echo "$('#idcomissao','#frmComissao').val('$cdseqcomissao');";
        echo "$('#dtcriacao','#frmComissao').val('$dtcriacao');";
	    echo "$('#idcomissao','#frmComissao').desabilitaCampo();";
        echo "$('#dtcriacao','#frmComissao').desabilitaCampo();";
	    echo "$('#nmcomissao','#frmComissao').focus();"; 
        exit();
    }		
?>
