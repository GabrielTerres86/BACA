<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Marcel Kohls /AMCom
 * DATA CRIAÇÃO : 20/03/2018
 * OBJETIVO     : Cabeçalho para a tela ATVPRB
 */
 ?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">
	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
    <?php if(in_array('H', $glbvars['opcoesTela'])) : ?>
			<option value="H" <?php echo $cddopcao == 'H' ? 'selected' : '' ?> >H - Hist&oacute;rico de envios para o BACEN</option>
		<?php endif; ?>
		<?php if(in_array('C', $glbvars['opcoesTela'])) : ?>
			<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?> >C - Cadastros</option>
		<?php endif; ?>
	</select>

	<a href="#" class="botao" id="btnOk">Ok</a>
	<br style="clear:both" />
</form>
