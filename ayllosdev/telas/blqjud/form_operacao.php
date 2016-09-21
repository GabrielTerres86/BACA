<?
/*!
 * FONTE        : form_operacao.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Lista de Operacoes para tela BLQJUD
 * --------------
 * ALTERAÇÕES   :
 *					   
 * --------------
 */
?>
<div id="divOperacao" style='display:none;'>
    <form id="frmOperacao" name="frmOperacao" class="formulario" onsubmit="return false;">
	<fieldset>
		<legend><? echo utf8ToHtml('Opera&ccedil;&otilde;es dispon&iacute;veis'); ?></legend>

        <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
            
        <label for="cdoperac"><? echo utf8ToHtml('Opera&ccedil;&atilde;o:') ?></label>
        <select id="cdoperac" name="cdoperac">
            <option value="I" <? echo $cdoperac == 'I' ? 'selected' : '' ?> > I - <? echo utf8ToHtml('Incluir') ?></option>
            <option value="A" <? echo $cdoperac == 'A' ? 'selected' : '' ?> > A - <? echo utf8ToHtml('Alterar') ?></option>
            <option value="C" <? echo $cdoperac == 'C' ? 'selected' : '' ?> > C - <? echo utf8ToHtml('Consultar') ?></option>
            <option value="D" <? echo $cdoperac == 'D' ? 'selected' : '' ?> > D - <? echo utf8ToHtml('Desbloquear') ?></option>
        </select>
        <a href="#" class="botao" id="btnOK" name="btnOK" onclick="botaoOK2();" >OK</a>

        <br style="clear:both" />	
    </fieldset>
    </form>

</div>
