<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIA��O      : Fabricio
 * DATA CRIA��O : 28/02/2013
 * OBJETIVO     : Cabe�alho para a tela ICFJUD
 * --------------
 * ALTERA��ES   :
 * --------------
 */

?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?> > I - <? echo utf8ToHtml('Incluir Informa&ccedil;&otilde;es do Cliente') ?></option>
		<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?> > C - <? echo utf8ToHtml('Consultar Informa&ccedil;&otilde;es do Cliente') ?></option>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
	
	<br style="clear:both" />	
	
</form>
</div>