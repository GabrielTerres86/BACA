<?
/*!
 * FONTE        : form_ralatorio_efetivo.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulário de relatorio efetivo - Tela RATBND
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
?>

<div id="tabRelRatingOpe">
    <form id="frmRelRatingOpe" name="frmImpressao" class="formulario">
        <fieldset>
            <br />
            <div id="tabRelConta">
                <label for="nrdctarl"><? echo utf8ToHtml('Conta/dv:') ?></label>
                <input id="nrdctarl" name="nrdctarl" class="conta" type="text"/>
                <label for="nmtitul"><? echo utf8ToHtml('Nome:') ?></label>
                <input name="nmtitul" id="nmtitul" type="text" value="<? echo $nmprimtl ?>" />
            </div>
            <label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
            <input type="text" id="cdagenci" name="cdagenci" class="campo" value="<? echo $cdagenci ?>"/>
            <label for="dtiniper"><? echo utf8ToHtml('Data:') ?></label>
            <input type="text" id="dtiniper" name="dtiniper" class="data"/>
            <label for="dtfimper"><? echo utf8ToHtml('até:') ?></label>
            <input type="text" id="dtfimper" name="dtfimper" class="data"/>
        </fieldset>
    </form>
</div>