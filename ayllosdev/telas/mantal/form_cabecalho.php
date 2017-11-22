<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/06/2011
 * OBJETIVO     : Cabeçalho para a tela MANTAL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onsubmit="return false;">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="B" <? echo $cddopcao == 'B' ? 'selected' : '' ?> > B </option>
		<option value="D" <? echo $cddopcao == 'D' ? 'selected' : '' ?> > D </option> 
	</select>
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="image" src="<?php echo $UrlImagens; ?>/botoes/ok.gif">
	
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($registros[0]->tags,'nmprimtl') ?>" />
			
	<br style="clear:both" />	
	
</form>