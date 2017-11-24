<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 06/09/2017
 * OBJETIVO     : Cabeçalho para a tela UPPGTO
 * --------------
 * ALTERAÇÕES   : 
 *
 *
 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" onchange="document.getElementById('btnOk1').click();">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>><? echo utf8ToHtml('C - Consultar remessas.') ?></option>
	<option value="T" <?php echo $cddopcao == 'T' ? 'selected' : '' ?>><? echo utf8ToHtml('T - Remessa de agendamento de pagamento de títulos.') ?></option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>><? echo utf8ToHtml('R - Imprimir relatórios.') ?></option>
    <option value="L" <?php echo $cddopcao == 'L' ? 'selected' : '' ?>><? echo utf8ToHtml('L - Log de movimentação de arquivos.') ?></option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>


