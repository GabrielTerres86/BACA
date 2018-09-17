<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 24/03/2017
 * OBJETIVO     : Rotina para buscar os dados
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    $xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <flghabilitado>2</flghabilitado>"; // Habilitado (0-Nao/1-Sim/2-Todos)
	$xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $registros = $xmlObject->roottag->tags[0];

    echo "$('#vlminimo_emprestado',    '#frmPrmpos').val('".getByTagName($registros->tags,'VLMINIMO_EMPRESTADO')."');";
    echo "$('#vlmaximo_emprestado',    '#frmPrmpos').val('".getByTagName($registros->tags,'VLMAXIMO_EMPRESTADO')."');";
    echo "$('#qtdminima_parcela',      '#frmPrmpos').val('".getByTagName($registros->tags,'QTDMINIMA_PARCELA')."');";
    echo "$('#qtdmaxima_parcela',      '#frmPrmpos').val('".getByTagName($registros->tags,'QTDMAXIMA_PARCELA')."');";

    $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA_INDEX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $registros = $xmlObject->roottag->tags[0]->tags;

    $strLinha = '';
    foreach ($registros as $reg) {
        $cddindex      = getByTagName($reg->tags,'CDDINDEX');
        $tpatualizacao = getByTagName($reg->tags,'TPATUALIZACAO');
        echo "$('#tpatualizacao_".$cddindex."', '#frmPrmpos').val(".$tpatualizacao.").desabilitaCampo();";
    }

    $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA_CARENCIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $registros = $xmlObject->roottag->tags[0]->tags;

    $htmBodyCarencia = '';
    $bg_class = 'corImpar';
    foreach ($registros as $reg) {
        $idcarencia       = getByTagName($reg->tags,'IDCARENCIA');
        $dscarencia       = getByTagName($reg->tags,'DSCARENCIA');
        $qtddias          = getByTagName($reg->tags,'QTDDIAS');
        $checked          = (getByTagName($reg->tags,'FLGHABILITADO') ? 'checked' : '');
        $htmBodyCarencia .= '<tr class="'.$bg_class.'">';
        $htmBodyCarencia .=    '<td style="text-align: center;"><input class="clsCheck clsInput" type="checkbox" id="flghabilitado_'.$idcarencia.'" name="flghabilitado_'.$idcarencia.'" '.$checked.'/></td>';
        $htmBodyCarencia .=    '<td style="padding-left: 5px;">'.$dscarencia.'</td>';
        $htmBodyCarencia .=    '<td style="text-align: center;">'.$qtddias.'</td>';
        $htmBodyCarencia .= '</tr>';
        $bg_class         = ($bg_class == 'corImpar' ? 'corPar' : 'corImpar');
    }
    echo "$('#htmBodyCarencia', '#frmPrmpos').html('".$htmBodyCarencia."');";
?>