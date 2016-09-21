<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 10/02/2012
 * OBJETIVO     : Cabeçalho para a tela COBRAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" onchange="document.getElementById('btnOk1').click();">
	<option value="C" <?php echo $cddopcao == 'C' ? 'selected' : '' ?>><? echo utf8ToHtml('C - Consultar informações de boletos cadastrados no sistema.') ?></option>
	<option value="I" <?php echo $cddopcao == 'I' ? 'selected' : '' ?>><? echo utf8ToHtml('I - Integrar arquivos de cobrança.') ?></option>
	<option value="R" <?php echo $cddopcao == 'R' ? 'selected' : '' ?>><? echo utf8ToHtml('R - Imprimir relatórios e consultar na tela.') ?></option>
	</select>

	<a href="#" class="botao" id="btnOk1">Ok</a>
	<br style="clear:both" />	

</form>


