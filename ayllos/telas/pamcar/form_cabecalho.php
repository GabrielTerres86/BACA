<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 07/12/2011
 * OBJETIVO     : Cabeçalho para a tela PAMCAR
 * --------------
 * ALTERAÇÕES   : 08/02/2012 - Retirando o atributo onClick do botão OK (Adriano).
 *
 *				  06/03/2013 - Novo layout padrao (Gabriel).
 * --------------
 */

?>
<div id="divCab">
<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input id="registro" name="registro" type="hidden" value=""  />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="L" <? echo $cddopcao == 'L' ? 'selected' : '' ?> > L - Limite Operacional</option> 
		<option value="H" <? echo $cddopcao == 'H' ? 'selected' : '' ?> > H - <? echo utf8ToHtml('Habilitar Convênio') ?></option>
		<option value="P" <? echo $cddopcao == 'P' ? 'selected' : '' ?> > P - <? echo utf8ToHtml('Processar Arquivos de Débito') ?></option>
		<option value="X" <? echo $cddopcao == 'X' ? 'selected' : '' ?> > X - Log do Processamento </option>
		<option value="R" <? echo $cddopcao == 'R' ? 'selected' : '' ?> > R - <? echo utf8ToHtml('Relatórios') ?></option>
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>	
		
	<br style="clear:both" />	
	
</form>
</div>