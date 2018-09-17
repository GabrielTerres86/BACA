<? 
/*!
 * FONTE        : validar.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 12/07/2016
 * OBJETIVO     : Rotina para validar tela CADPAC
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : '';
    $nrdcaixa = (isset($_POST['nrdcaixa'])) ? $_POST['nrdcaixa'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
    
    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";		
    $xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= "   <nrdcaixa>".$nrdcaixa."</nrdcaixa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_CADPAC", "CADPAC_VALIDA_CAIXA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $arrErro = explode("###", $msgErro);
        $msgErro = $arrErro[0];
        $nmCampo = $arrErro[1];
        $nmFunca = $nmCampo ? "$('#".$nmCampo."', '#frmCadpac').focus();" : '' ;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$nmFunca,false);
    }

    $registros = $xmlObjeto->roottag->tags[0];

    echo "$('#cdopercx', '#frmCadpac').val('".getByTagName($registros->tags,'CDOPERCX')."');";
    echo "$('#dtdcaixa', '#frmCadpac').val('".getByTagName($registros->tags,'DTDCAIXA')."');";
    echo "$('#rowidcxa', '#frmCadpac').val('".getByTagName($registros->tags,'ROWIDCXA')."');";

    // Se retornou algum erro mas mesmo assim tem que exibir a tela
    $dserrocx = getByTagName($registros->tags,'DSERROCX');
    if ($dserrocx) {
        exibirErro('error',utf8_encode($dserrocx),'Alerta - Ayllos','$(\'#nrdcaixa\', \'#frmCadpac\').focus()',false);
    } else {
        echo "hideMsgAguardo();";
        echo "$('#cdopercx', '#frmCadpac').habilitaCampo().focus();";
        echo "$('#dtdcaixa', '#frmCadpac').habilitaCampo();";
        echo "$('#nrdcaixa', '#frmCadpac').desabilitaCampo();";
        echo "trocaBotao('Gravar','confirmaAcao()','carregaTelaCadpac()');";
    }
?>