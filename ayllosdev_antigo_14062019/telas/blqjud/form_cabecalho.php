<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Cabeçalho para tela BLQJUD
 * --------------
 * ALTERAÇÕES   : 04/11/2016 - Removida da tela a op~c"ao
 *					   
 * --------------
 */
?>
<div id="divCab" style='display:none;'>
<form id="frmCab" name="frmCab" class="formulario cabecalho"  onsubmit="return false;">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="B" <? echo $cddopcao == 'B' ? 'selected' : '' ?> > B - <? echo utf8ToHtml('Bloqueio Judicial') ?></option>
        <option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - <? echo utf8ToHtml('Bloqueio do Capital') ?></option>
		<!--option value="T" <? echo $cddopcao == 'T' ? 'selected' : '' ?> > T - <? echo utf8ToHtml('Transfer&ecirc;ncia Judicial') ?></option-->
		<option value="R" <? echo $cddopcao == 'R' ? 'selected' : '' ?> > R - <? echo utf8ToHtml('Relat&oacute;rio') ?></option>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
	
	<br style="clear:both" />	
	
</form>
</div>
		