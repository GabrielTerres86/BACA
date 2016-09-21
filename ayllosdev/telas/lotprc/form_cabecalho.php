<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 07/05/2013
 * OBJETIVO     : Cabeçalho para a tela LOTPRC
 * --------------
 * ALTERAÇÕES   : 14/10/2013 - Adicionado opcao "W" e "R". (Jorge).
 * --------------
 */
?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao">
		<option value="N" <?php echo $cddopcao == 'N' ? 'selected' : '' ?>><? echo utf8ToHtml('N - Novo lote.') ?></option>
		<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>><? echo utf8ToHtml('I - Incluir conta no lote.') ?></option>
		<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>><? echo utf8ToHtml('C - Consultar conta no lote.') ?></option>
		<option value="A" <?php echo $cddopcao == 'A' ? 'selected' : '' ?>><? echo utf8ToHtml('A - Alterar conta do lote.') ?></option>
		<option value="E" <?php echo $cddopcao == 'E' ? 'selected' : '' ?>><? echo utf8ToHtml('E - Excluir conta do lote.') ?></option>
		<option value="W" <?php echo $cddopcao == 'W' ? 'selected' : '' ?>><? echo utf8ToHtml('W - Incluir informações no lote.') ?></option>
		<option value="F" <?php echo $cddopcao == 'F' ? 'selected' : '' ?>><? echo utf8ToHtml('F - Fechar lote.') ?></option>
		<option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?>><? echo utf8ToHtml('L - Reabrir lote.') ?></option>
		<option value="Z" <?php echo $cddopcao == 'Z' ? 'selected' : '' ?>><? echo utf8ToHtml('Z - Finalizar lote.') ?></option>
		<option value="G" <?php echo $cddopcao == 'G' ? 'selected' : '' ?>><? echo utf8ToHtml('G - Gerar arquivo para encaminhamento ao BRDE.') ?></option>
		<!-- <option value="T" <?php //echo $cddopcao == 'T' ? 'selected' : '' ?>><?php //echo utf8ToHtml('T - Gerar arquivo final ao BRDE.') ?></option> -->
		<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>><? echo utf8ToHtml('R - Relatório do lote.') ?></option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>