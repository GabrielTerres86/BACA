<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 23/02/2012
 * OBJETIVO     : Cabeçalho para a tela TRAESP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
	</select>
	<a href="#" class="botao" id="btnOK"   onclick="setaOpcao(); return false;" >OK</a>
	
	<br style="clear:both" />	
	
</form>
</div>