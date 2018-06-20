<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Hélinton Steffens (Supero)
 * DATA CRIAÇÃO : 12/03/2018
 * OBJETIVO     : Cabeçalho para a tela MANPRT
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil&atildeo:') ?></label>
	<select id="cddopcao" name="cddopcao" onchange="document.getElementById('btnOk1').click();">
	<option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>><? echo utf8ToHtml('T - Consultar TEDs.') ?></option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>><? echo utf8ToHtml('R - Consultar custas cartor&aacuterias X tarifas (custo do servi&ccedilo).') ?></option>
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>><? echo utf8ToHtml('C - Consultar Concilia&ccedil&otildees.') ?></option>
	<option value="E" <?php echo $cddopcao == 'E' ? 'selected' : '' ?>><? echo utf8ToHtml('E - Consultar Extrato Consolidado.') ?></option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>


