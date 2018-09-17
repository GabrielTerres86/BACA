<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : 20/07/2011
 * OBJETIVO     : Cabeçalho para a tela CMEDEP
 * --------------
 * ALTERAÇÕES   : 19/07/2012 - Adicionado campo nrdconta no formulario. (Jorge)
 * --------------
 */ 
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onsubmit="return false;">
		
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<?php for ($i = 0; $i < count($opcoesTela); $i++) { ?>
		<option value="<?php echo $opcoesTela[$i]; ?>1"<?php if ($opcoesTela[$i] == 'I') { echo " selected"; } ?>><?php echo $opcoesTela[$i]; ?></option>
		<?php } ?>	
	</select>
	
	<label for="dtdepesq">Data:</label>
	<input type="text" id="dtdepesq" name="dtdepesq" value="<? echo $dtdepesq == '' ? '' : $dtdepesq ?>" />
	
	<label for="cdagenci">PAC:</label>
	<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci == 0 ? '' : $cdagenci ?>" />
	
	<label for="cdbccxlt">Bco/Cxa:</label>
	<input type="text" id="cdbccxlt" name="cdbccxlt" value="<? echo $cdbccxlt == 0 ? '' : $cdbccxlt ?>" />

	<label for="nrdolote">Lote:</label>
	<input type="text" id="nrdolote" name="nrdolote" value="<? echo $nrdolote == 0 ? '' : $nrdolote ?>" />
	
	<br style="clear:both" />	
	
	<label for="nrdocmto">Docmto:</label>
	<input type="text" id="nrdocmto" name="nrdocmto" value="<? echo $nrdocmto == 0 ? '' : $nrdocmto ?>" />
	
	<label for="nrdconta">Conta/Dv:</label>
	<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" />
	
	<br style="clear:both" />
</form>