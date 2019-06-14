<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Cabeçalho Principal - Tela RATBND
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

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:block">
    <table width ="100%">
        <tr>
            <td>
                <label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
                <select id="cddopcao" name="cddopcao">
                    <option value="C" selected ><? echo utf8ToHtml('C - Consulta') ?> </option>
                    <option value="I" ><? echo utf8ToHtml('I - Inclusão')?> </option>
                    <option value="A" ><? echo utf8ToHtml('A - Alteração')?> </option>
                    <option value="E" ><? echo utf8ToHtml('E - Efetivação')?> </option>
                    <option value="R" ><? echo utf8ToHtml('R - Relatório')?> </option>
                </select>
                <a href="#" class="botao" id="btnOK" style="text-align:right;">OK</a>
            </td>
        </tr>
    </table>
</form>

<form id="frmConta" name="frmConta" class="formulario" style="display:none">
    <fieldset>
        <br/>
        <label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
        <input id="nrdconta" name="nrdconta" type="text"/>
        <label for="nmprimtl"><? echo utf8ToHtml('Nome:') ?></label>
        <input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $nmprimtl ?>" />

        <a href="#" class="botao" id="btnOkConta" style="text-align:right;">OK</a>
    </fieldset>
</form>

<div id="divResultado" style="display:block;">
</div>

<form name="frmImprimir" id="frmImprimir" style="display:none">
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

    <input name="nrdconta" id="nrdconta" type="hidden" value="" />
    <input name="cdagenci" id="cdagenci" type="hidden" value="" />
    <input name="cddopcao" id="cddopcao" type="hidden" value="" />
    <input name="dtiniper" id="dtiniper" type="hidden" value="" />
    <input name="dtfimper" id="dtfimper" type="hidden" value="" />
    <input name="tppesqui" id="tppesqui" type="hidden" value="" />
    <input name="nrctrato" id="nrctrato" type="hidden" value="" />
    <input name="cdoperad" id="cdoperad" type="hidden" value="" />
    <input name="tpctrato" id="tpctrato" type="hidden" value="" />

</form>