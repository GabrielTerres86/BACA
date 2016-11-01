<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 15/12/2014
 * OBJETIVO     : Rotina para alteração cadastral da tela CADRIS
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
    $innivris = (isset($_POST['innivris'])) ? $_POST['innivris'] : '';
    $dsjustif = (isset($_POST['dsjustif'])) ? $_POST['dsjustif'] : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";		
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "   <cdnivel_risco>".$innivris."</cdnivel_risco>";
    $xml .= "   <dsjustificativa>".utf8_decode($dsjustif)."</dsjustificativa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

	if ($cddopcao == 'E') { // Exclusao
        $nmdeacao = 'EXCLUI_RISCO';
        $dsmensag = 'Conta(s) exclu&iacute;da(s) com sucesso!';
	} else { // Inclusao
        $nmdeacao = 'INCLUI_RISCO';
        $dsmensag = 'Conta inclu&iacute;da com sucesso!';
    }

    $xmlResult = mensageria($xml, "TELA_CADRIS", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
        }
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',"",false);
    }

    echo "hideMsgAguardo();";    
    echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","carregaTelaCadris();");';
?>