<?
/*!
 * FONTE        : form_contrato.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulário de Contrato - Tela RATBND
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

<div id="divContrato" >
    <form id="frmContrato" name="frmContrato" class="formulario" style="display:none">
    <fieldset>
        <br />
        <label for="nrctrato"><? echo utf8ToHtml('Contrato:') ?></label>
        <select id="nrctrato" name="nrctrato">
        <? for ($i = 0; $i < $qtContratos; $i++){
            $nrctrato = getByTagName($contratos[$i]->tags,"nrctrato");
        ?>
            <option value="<?php echo $nrctrato ?>"><?php echo $nrctrato ?></option>
        <? } ?>
        </select>
        <a href="#" class="botao" id="btnOkContrato"  onClick="consultaRating();" >OK</a>
        <label for="vlempbnd"><? echo utf8ToHtml('Valor:') ?></label>
        <input id="vlempbnd" name="vlempbnd" type="text" value="<? echo $vlctrbnd ?>"/>
        <label for="qtparbnd"><? echo utf8ToHtml('Qtd. Prestacao:') ?></label>
        <input id="qtparbnd" name="qtparbnd" type="text" value="<? echo $qtparbnd ?>"/>
    </fieldset>
    </form>
</div>
<div id="divResultados">
</div>