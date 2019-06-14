<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 10/02/2017
 * OBJETIVO     : Rotina para inclusao/alteracao da tela CADFRA
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

	$cddopcao   = (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : '';
	$cdoperacao = (isset($_POST['cdoperacao'])) ? $_POST['cdoperacao'] : 0;
    $tpoperacao = (isset($_POST['tpoperacao'])) ? $_POST['tpoperacao'] : 0;
    $hrretencao = (isset($_POST['hrretencao'])) ? $_POST['hrretencao'] : '';

    $flgemail_entrega  = (isset($_POST['flgemail_entrega']))  ? $_POST['flgemail_entrega']  : 0;
    $dsemail_entrega   = (isset($_POST['dsemail_entrega']))   ? $_POST['dsemail_entrega']   : '';
    $dsassunto_entrega = (isset($_POST['dsassunto_entrega'])) ? $_POST['dsassunto_entrega'] : '';
    $dscorpo_entrega   = (isset($_POST['dscorpo_entrega']))   ? $_POST['dscorpo_entrega']   : '';

    $flgemail_retorno  = (isset($_POST['flgemail_retorno']))  ? $_POST['flgemail_retorno']  : 0;
    $dsemail_retorno   = (isset($_POST['dsemail_retorno']))   ? $_POST['dsemail_retorno']   : '';
    $dsassunto_retorno = (isset($_POST['dsassunto_retorno'])) ? $_POST['dsassunto_retorno'] : '';
    $dscorpo_retorno   = (isset($_POST['dscorpo_retorno']))   ? $_POST['dscorpo_retorno']   : '';
    $flgativo          = (isset($_POST['flgativo']))          ? $_POST['flgativo']   : 0;
    $tpretencao        = (isset($_POST['tpretencao']))        ? $_POST['tpretencao']   : 1;
    

    $strhoraminutos    = (isset($_POST['strhoraminutos']))    ? $_POST['strhoraminutos']    : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";		
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <cdoperacao>".$cdoperacao."</cdoperacao>";
    $xml .= "   <tpoperacao>".$tpoperacao."</tpoperacao>";
    $xml .= "   <hrretencao>".$hrretencao."</hrretencao>";
    $xml .= "   <strhoraminutos>".$strhoraminutos."</strhoraminutos>";
    $xml .= "   <flgemail_entrega>".$flgemail_entrega."</flgemail_entrega>";
    $xml .= "   <dsemail_entrega>".utf8_decode($dsemail_entrega)."</dsemail_entrega>";
    $xml .= "   <dsassunto_entrega>".utf8_decode($dsassunto_entrega)."</dsassunto_entrega>";
    $xml .= "   <dscorpo_entrega><![CDATA[".utf8_decode($dscorpo_entrega)."]]></dscorpo_entrega>";
    $xml .= "   <flgemail_retorno>".$flgemail_retorno."</flgemail_retorno>";
    $xml .= "   <dsemail_retorno>".utf8_decode($dsemail_retorno)."</dsemail_retorno>";
    $xml .= "   <dsassunto_retorno>".utf8_decode($dsassunto_retorno)."</dsassunto_retorno>";
    $xml .= "   <dscorpo_retorno><![CDATA[".utf8_decode($dscorpo_retorno)."]]></dscorpo_retorno>";
    $xml .= "   <flgativo>".$flgativo."</flgativo>";
    $xml .= "   <tpretencao>".$tpretencao."</tpretencao>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CADFRA", ($cddopcao == 'A' ? 'CADFRA_GRAVA' : 'CADFRA_EXCLUI'), $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $arrErro = explode("###", $msgErro);
        $msgErro = $arrErro[0];
        $nmCampo = $arrErro[1];
        $nmOpAba = "acessaOpcaoAba('".$arrErro[2]."');";
        $nmFunca = $nmCampo ? $nmOpAba."$('#".$nmCampo."', '#frmCadfra').focus();" : '' ;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$nmFunca,false);
    }

    echo "hideMsgAguardo();";    
    echo 'showError("inform","Dados '.($cddopcao == 'A' ? 'gravados' : 'excluidos').' com sucesso!","Alerta - Ayllos","carregaTelaCadfra();");';
?>