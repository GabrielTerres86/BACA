<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe o POST
$dtinicio = (!empty($_POST['dtinicio'])) ? $_POST['dtinicio'] : null;
$vlrfinal = (!empty($_POST['vlrfinal'])) ? $_POST['vlrfinal'] : null;
$cartorio = (!empty($_POST['cartorio'])) ? $_POST['cartorio'] : null;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
    exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <dtinicial>".$dtinicio."</dtinicial>";
$xml .= "   <vlfinal>".$vlrfinal."</vlfinal>";
//$xml .= "   <cartorio>".$cartorio."</cartorio>";
$xml .= "   <cartorio></cartorio>";
$xml .= " </Dados>";
$xml .= "</Root>";
//print_r($xml);exit;
$xmlResult = mensageria($xml, "TELA_MANPRT", "CONSULTA_NAO_CONCILIADOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
    exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
}

$registros 	= $xmlObjeto->roottag->tags[0]->tags;
?>
<table style="table-layout: fixed;">
    <thead>
        <tr>
            <th>&nbsp;</th>
            <th>Cart&oacute;rio</th>
            <th>Cooperativa</th>
            <th>Convenio</th>
            <th>Conta</th>
            <th>Doc.</th>
            <th>Data</th>
            <th>Vlr.</th>
        </tr>
    </thead>
    <tbody>
        <? foreach( $registros as $result ) { ?>
            <tr>
                <td><input type="checkbox" class="clsCheckbox" onclick="verificaCheckbox(this, <? echo getByTagName($result->tags,'vltitulo'); ?>);"
                        value="<? echo getByTagName($result->tags,'idretorno'); ?>" /></td>
                <td width="210">
                    <? echo getByTagName($result->tags,'nmcartorio'); ?>
                </td>
                <td width="120">
                    <? echo getByTagName($result->tags,'nmrescop'); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'nrcnvcob'); ?>
                </td>
                <td width="80">
                    <? echo formataContaDV(getByTagName($result->tags,'nrdconta')); ?>
                </td>
                <td width="65">
                    <? echo getByTagName($result->tags,'nrdocmto'); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'dtocorre'); ?>
                </td>
                <td width="80">
                    <? echo number_format(str_replace(",","",getByTagName($result->tags,'vltitulo')),2,",","."); ?>
                </td>
            </tr>
            <? } ?>
    </tbody>
</table>