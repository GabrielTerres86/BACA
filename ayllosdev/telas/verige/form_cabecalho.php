<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Carlos (CECRED)
 * DATA CRIAÇÃO : 11/11/2013											ÚLTIMA ALTERAÇÃO: 
 * OBJETIVO     : Cabeçalho para a tela VERIGE
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 *                
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
    <div style="width:350px; margin:0 auto"><center>
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Entre com a opcao desejada (C,R).">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> ><? echo utf8ToHtml('C - Consultar grupo econômico')?></option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?> ><? echo utf8ToHtml('R - Imprimir relatório grupo econômico')?></option>
	</select>

	<div id="divconta" name="divconta">
		<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="nrdconta" id="nrdconta" type="text" />
		<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	</div>
	
	<div id="divagenci" name="divagenci">
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input name="cdagenci" id="cdagenci" type="text" value="<?php echo $cdagencx ?>" alt="Pressione 'F7' para Zoom."/>
		<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	</div>
	</center>
	</div>
	<br style="clear:both" />	
</form>