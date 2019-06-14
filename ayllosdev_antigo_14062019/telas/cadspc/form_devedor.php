<?
/*!
 * FONTE        : form_devedor.php
 * CRIA��O      : Rogerius Milit�o (DB1)
 * DATA CRIA��O : 06/03/2012
 * OBJETIVO     : Formulario do devedor
 * --------------
 * ALTERA��ES   :
 * --------------
 */
 ?>

<form id="frmDevedor" name="frmDevedor" class="formulario">

	<fieldset>
	
		<legend> <? echo utf8ToHtml('Devedor');  ?> </legend>	
		
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>

		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="tpidenti">Identificacao:</label>
		<select id="tpidenti" name="tpidenti">
		<option value="1" <?php echo $tpidenti == '1' ? 'selected' : '' ?> >1-Devedor 1</option>
		<option value="3" <?php echo $tpidenti == '3' ? 'selected' : '' ?> >3-Fiador 1</option>
		<option value="4" <?php echo $tpidenti == '4' ? 'selected' : '' ?> >4-Fiador 2</option>
		</select>
		
	</fieldset>	

</form>	