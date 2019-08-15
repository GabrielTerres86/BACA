<?php
/*
  16/04/2019 - INC0011935 - Melhorias diversas nos layouts de teds e conciliação:
               - modal de conciliação arrastável e correção das colunas para não obstruir as caixas de seleção;
               - aumentadas as alturas das listas de teds e modal de conciliação, reajustes das colunas (Carlos)
*/
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
    exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}

// Recebe o POST
$dtinicio = (!empty($_POST['dtinicio'])) ? $_POST['dtinicio'] : null;
$vlrfinal = (!empty($_POST['vlrfinal'])) ? str_replace(',', '.', str_replace('.', '', $_POST['vlrfinal'])) : null;
$cartorio = (!empty($_POST['cartorio'])) ? $_POST['cartorio'] : null;

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <dtinicial>".$dtinicio."</dtinicial>";
$xml .= "   <vlfinal>".$vlrfinal."</vlfinal>";
//$xml .= "   <cartorio>".$cartorio."</cartorio>";
$xml .= "   <cartorio></cartorio>";
$xml .= " </Dados>";
$xml .= "</Root>";

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
            <th width="20">&nbsp;</th>
            <th>Cart&oacute;rio</th>
            <th>Cooperativa</th>
            <th>UF</th>
            <th>Convenio</th>
            <th>Conta</th>
            <th>Doc.</th>
            <th>Data</th>
            <th>Vlr.</th>
			<th>Vlr.Saldo</th>
        </tr>
    </thead>
    <tbody>
        <? //foreach( $registros as $result ) { ?>
        <? for ( $i = 0; $i < count($registros)-1; $i++ ) { $result = $registros[$i]; ?>
            <tr>
                <td width="20"><input name="idsTitulo" type="checkbox" class="clsCheckbox" onclick="verificaCheckbox(this, <? echo getByTagName($result->tags,'vltitulo_saldo'); ?>);"
                        value="<? echo getByTagName($result->tags,'idretorno'); ?>" /></td>
                <td width="210">
                    <? echo getByTagName($result->tags,'nmcartorio'); ?>
                </td>
                <td width="120">
                    <? echo getByTagName($result->tags,'nmrescop'); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'estado'); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'nrcnvcob'); ?>
                </td>
                <td width="65">
                    <? echo formataContaDV(getByTagName($result->tags,'nrdconta')); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'nrdocmto'); ?>
                </td>
                <td width="80">
                    <? echo getByTagName($result->tags,'dtocorre'); ?>
                </td>
                <td width="80">
                    <span><? echo getByTagName($result->tags,'vltitulo') ?></span>
                    <? echo number_format(str_replace(",","",getByTagName($result->tags,'vltitulo')),2,",","."); ?>
                </td>
				<td width="80">
                    <span><? echo getByTagName($result->tags,'vltitulo_saldo') ?></span>
                    <? echo number_format(str_replace(",","",getByTagName($result->tags,'vltitulo_saldo')),2,",","."); ?>
                </td>
            </tr>
            <? } ?>
    </tbody>
</table>