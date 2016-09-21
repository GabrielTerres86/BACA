<?
/*!
 * FONTE        : form_ralatorio.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulário de relatório - Tela RATBND
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

<div id="tabRelatSemRating">
    <form id="frmImpressao" name="frmImpressao" class="formulario">
    <fieldset>
        <br/>
        <label for="cdtiprel"><? echo utf8ToHtml('Tipo:') ?></label>
        <select id="cdtiprel" name="cdtiprel">
            <option value="S" selected ><? echo utf8ToHtml('S - Sem Rating Efetivo') ?> </option>
            <option value="R" ><? echo utf8ToHtml('R - Rating de Operações BNDES')?> </option>
        </select>
        <a href="#" class="botao" id="btnOkImpressao" >OK</a>
    </fieldset>
</form>
</div>
