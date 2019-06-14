<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 09/02/2017
 * OBJETIVO     : Rotina para buscar os dados
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Guardo os parâmetos do POST em variáveis	
    $cddopcao   = (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : 'C';
    $cdoperacao = (isset($_POST['cdoperacao'])) ? $_POST['cdoperacao'] : 0;
    $tpoperacao = (isset($_POST['tpoperacao'])) ? $_POST["tpoperacao"] : 0;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <cdoperacao>".$cdoperacao."</cdoperacao>";
    $xml .= "   <tpoperacao>".$tpoperacao."</tpoperacao>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CADFRA", "CADFRA_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $registros = $xmlObject->roottag->tags[0];
    $flentrega = (int) getByTagName($registros->tags,'FLGEMAIL_ENTREGA');
    $flretorno = (int) getByTagName($registros->tags,'FLGEMAIL_RETORNO');
    $dscorpent = preg_replace('/\r\n|\r|\n/','\n',getByTagName($registros->tags,'DSCORPO_ENTREGA'));
    $dscorpret = preg_replace('/\r\n|\r|\n/','\n',getByTagName($registros->tags,'DSCORPO_RETORNO'));
    
    echo "$('#tpretencao',        '#frmCadfra').val('".getByTagName($registros->tags,'TPRETENCAO')."');";
    echo "$('#hrretencao',        '#frmCadfra').val('".getByTagName($registros->tags,'HRRETENCAO')."');";
    echo "$('#hrretencao5',       '#frmCadfra').val('".getByTagName($registros->tags,'HRRETENCAO')."');";
    echo "$('#".($flentrega ? 'flgYes' : 'flgNo')."',  '#frmCadfra').prop('checked', true);";
    echo "$('#dsemail_entrega',   '#frmCadfra').val('".getByTagName($registros->tags,'DSEMAIL_ENTREGA')."');";
    echo "$('#dsassunto_entrega', '#frmCadfra').val('".getByTagName($registros->tags,'DSASSUNTO_ENTREGA')."');";
    echo "$('#dscorpo_entrega',   '#frmCadfra').val('".$dscorpent."');";
    echo "$('#".($flretorno ? 'flgYesRet' : 'flgNoRet')."',  '#frmCadfra').prop('checked', true);";
    echo "$('#dsemail_retorno',   '#frmCadfra').val('".getByTagName($registros->tags,'DSEMAIL_RETORNO')."');";
    echo "$('#dsassunto_retorno', '#frmCadfra').val('".getByTagName($registros->tags,'DSASSUNTO_RETORNO')."');";
    echo "$('#dscorpo_retorno',   '#frmCadfra').val('".$dscorpret."');";
    echo "$('#flgativo',          '#frmCadfra').val('".getByTagName($registros->tags,'FLGATIVO')."');";
    echo "$('#flgativo_ori',      '#frmCadfra').val('".getByTagName($registros->tags,'FLGATIVO')."');";

    if ($cddopcao == 'C') {
        echo "trocaBotao('','','carregaTelaCadfra()');";
    } else {
        echo "trocaBotao('".($cddopcao == 'A' ? 'Gravar' : 'Excluir')."','confirmaAcao()','carregaTelaCadfra()');";
    }

    echo "acessaOpcaoAba(0);"; // Carrega aba inicial    
    echo " $('#flgativo, #frmCadfra').focus();";

    

    // Se for ONLINE busca os intervalos
    if ($tpoperacao == 1) {

        $xmlResult = mensageria($xml, "TELA_CADFRA", "CADFRA_BUSCA_INTERV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObject = getObjectXML($xmlResult);

        if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
            exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
        }

        $regParam = $xmlObject->roottag->tags[0]->tags;

        foreach ($regParam as $reg) {
            $hrinicio   = getByTagName($reg->tags,'HRINICIO');
            $hrfim      = getByTagName($reg->tags,'HRFIM');
            $qtdminutos = getByTagName($reg->tags,'QTDMINUTOS_RETENCAO');
            $idLinParam = str_replace(':', '', $hrinicio).'_'.str_replace(':', '', $hrfim).'_'.$qtdminutos;
            $strLinha   = '<tr id="'.$idLinParam.'"><td width="130">'.$hrinicio.'</td><td width="130">'.$hrfim.'</td><td width="130">'.$qtdminutos.'</td><td>'.($cddopcao == 'A' ?'<img onclick="confirmaExclusao(\\\''.$idLinParam.'\\\');" style="cursor:hand;" src="../../imagens/geral/servico_nao_ativo.gif" width="17" height="17" />' : '-').'</td></tr>';
            echo "$('#tbodyHora', '#divHora').append('".$strLinha."');";
        }

        echo "formataGridHora();";
        echo "carregarStrHoraMinutos();";

    }
    
    echo " exibeIntervalo(".$tpoperacao."); ";    
    
    if ($cddopcao == 'C' || $cddopcao == 'E') {
        echo "$('input, select, textarea', '#frmCadfra').desabilitaCampo();";
        echo "$('#addInterv', '#frmCadfra').hide();";
    } else {
        echo "$('input, select, textarea', '#frmCadfra').habilitaCampo();";
        echo "$('#cdoperacao, #dsoperacao, #tpoperacao', '#frmCadfra').desabilitaCampo();";
        echo "$('#addInterv', '#frmCadfra').show();";
    }
?>