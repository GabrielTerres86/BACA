<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 19/07/2018
 * OBJETIVO     : Rotina para controlar as operações da tela CADRES
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

// Recebe a operação que está sendo realizada
$cddopcao    = (!empty($_POST['cddopcao']))    ? $_POST['cddopcao'] : '';
$cdcooper    = (!empty($_POST['cdcooper']))    ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$cdalcada    = (!empty($_POST['cdalcada']))    ? $_POST['cdalcada'] : '';
$dsemail     = (!empty($_POST['dsemail']))     ? $_POST['dsemail'] : '';
$cdaprovador = (!empty($_POST['cdaprovador'])) ? $_POST['cdaprovador'] : '';
$flregra     = (!isset($_POST['flregra']))     ? (int)$_POST['flregra'] : 0;

$flofesms    = (isset($_POST['flofesms']))    ? $_POST['flofesms'] : 0;
$dtiniofe    = (isset($_POST['dtiniofe']))    ? $_POST['dtiniofe'] : '';
$dtfimofe    = (isset($_POST['dtfimofe']))    ? $_POST['dtfimofe'] : '';
$dsmensag    = (isset($_POST['dsmensag']))    ? $_POST['dsmensag'] : '';
$fllindig    = (isset($_POST['fllindig']))    ? $_POST['fllindig'] : 0;
$nrdialau    = (isset($_POST['nrdialau']))    ? $_POST['nrdialau'] : 0;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}

// Opcao de Carregamento
if ( $cddopcao == 'A' || $cddopcao == 'C' ) {

    $xml = new XmlMensageria();
    $xml->add('dtmvtolt',$glbvars['dtmvtolt']);
    $xml->add('cddopcao','');
    $xml->add('flgerlog',0);
    $xml->add('nriniseq',1);
    $xml->add('nrregist',0);

    $xmlResult = mensageria($xml, "CADREG", "BUSCACRAPREG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $countReg = 0;
    } else {
        $countReg = (int) $xmlObj->roottag->attributes["QTREGIST"];
    }

	$xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);

    $xmlResult = mensageria($xml, "TELA_CADRES", "BUSCA_WORKFLOW", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    $html = '';
    //echo "$('#div_opcao_a').html('<div class=\"divRegistros\"></div>'); ";
    
    $html .='<div class="divRegistros">';
    $html .='<div class="divCabecalhoPesquisa" style="width:100%">';
    $html .='   <table><thead style="display:table-header-group">';
    $html .='   <tr>';
    $html .='       <th style="padding:0 5px" width="56">&nbsp;</th>';
    $html .='       <th style="padding:0 5px" width="361" align="left">Al&ccedil;ada</th>';
    $html .='       <th style="padding:0 5px" width="266">&nbsp;</th>';
    $html .='   </tr>';
    $html .='   </thead></table>';
    $html .='</div>';
    $html .='<table><tbody>';
    $i = 1;
    $registros = $xmlObj->roottag->tags[0]->tags;

    foreach ($registros as $r) {
        $i++;

        $cdalcada     = getByTagName($r->tags,"cdalcada_aprovacao");
        $dsalcada     = getByTagName($r->tags,"dsalcada_aprovacao");
        $flgregra     = getByTagName($r->tags,"flregra_aprovacao") == "1" ? "checked" : "";
        $disabled     = ( ( ( $countReg === 0 && $cdalcada == 1 ) || $cddopcao == 'C' ) ? 'disabled' : '' );
        
        $html .= "<tr>";
        $html .= "  <td width=\"56\" align=\"center\"> <input type=\"checkbox\" $flgregra id=\"alcada_$i\" name=\"chkalcada\" value=\"$cdalcada\" $disabled ></td>";
        $html .= "  <td width=\"361\"> $dsalcada </td>";
        $html .= "  <td width=\"266\" align=\"center\"> <a href=\"#\" class=\"botao ".($disabled && $cddopcao == 'A' ? 'botaoDesativado' : '')."\" style=\"margin:3px 0\" onclick=\"Grid.onClick_Aprovadores($cdalcada)\" $disabled>Aprovadores</a></td>";
        $html .= '</tr>';
    }
    $html .= '</tbody></table>';
    $html .= '<hr style="background-color:#666; height:1px;" />';
    $html .= '</div>';
    $html .= '<div id="divBotoes" style="margin-bottom: 10px;">';
    $html .= '  <a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;">Voltar</a>';
    if ($cddopcao == 'A') {
        $html .= '  <a href="#" class="botao" id="btProsseguir" onclick="FormularioPacote.onClick_Prosseguir();">Gravar</a>';
    }
    $html .= '</div>';

    //echo "hideMsgAguardo();";
    echo $html;
    //echo "$('div.divRegistros', '#div_opcao_a').html('$html');";    
    return false;
    
// Opcao de Gravação
} else if ( $cddopcao == 'AX' ){

    $xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);
    $xml->add('cdalcada_aprovacao',$cdalcada);
    $xml->add('cdaprovador',$cdaprovador);
    $xml->add('dsemail_aprovador',$dsemail);

    $xmlResult = mensageria($xml, "TELA_CADRES", "INSERE_APROVADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    echo 'showError("inform","Aprovador adicionado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","PopupAprovadores.carregarGridAprovadores(\"'.$cdalcada.'\");blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';

// Opcao de Gravação
} else if ( $cddopcao == 'FX' ){

    $xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);
    $xml->add('cdalcada_aprovacao',$cdalcada);
    $xml->add('flregra_aprovacao',$flregra);

    $xmlResult = mensageria($xml, "TELA_CADRES", "ATUALIZA_ALCADA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    echo 'showError("inform","Al&ccedil;ada atualizada.","Notifica&ccedil;&atilde;o - Ayllos","");';

// Opcao de Exclusão
} else if ( $cddopcao == 'EX' ) {
    $xml = new XmlMensageria();
    $xml->add('cdcooper',$cdcooper);
    $xml->add('cdalcada_aprovacao',$cdalcada);
    $xml->add('cdaprovador',$cdaprovador);

    $xmlResult = mensageria($xml, "TELA_CADRES", "EXCLUIR_APROVADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
        exibeErroNew($msgErro);exit;
    }

    echo 'showError("inform","Aprovador removido com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","PopupAprovadores.carregarGridAprovadores(\"'.$cdalcada.'\");blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");');
}