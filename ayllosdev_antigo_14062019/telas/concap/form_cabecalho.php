<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Novembro/2013
 * OBJETIVO     : Cabe�alho para tela CONCAP
 * --------------
 * ALTERA��ES   :
 *					   
 * --------------
 */
?>
<div id="divCab" style='display:none;'>
<form id="frmCab" name="frmCab" class="formulario cabecalho"  onsubmit="return false;">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="T" <? echo $cddopcao == 'T' ? 'selected' : '' ?> > T - <? echo utf8ToHtml('Terminal') ?></option>
		<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > I - <? echo utf8ToHtml('Impress&atilde;o') ?></option>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" style="text-align:right;">OK</a>
	
	<br style="clear:both" />	
	
</form>
</div>
		