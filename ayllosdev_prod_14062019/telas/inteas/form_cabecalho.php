<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 14/04/2016
 * OBJETIVO     : Cabeçalho para a tela INTEAS
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */

?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="G" <? echo $cddopcao == 'G' ? 'selected' : '' ?> > G - Gerar arquivo de integra&ccedil;&atilde;o</option> 		
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>	
		
	<br style="clear:both" />	
	
</form>
</div>