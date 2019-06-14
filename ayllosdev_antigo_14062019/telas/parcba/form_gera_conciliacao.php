<?php
	/*!
	 * FONTE        : form_cadastro_tarifa.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Cadastro de parametros para a tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divGeraConciliacao" name="divGeraConciliacao">
	<form id="frmGeraConciliacao" name="frmGeraConciliacao" class="formulario" onSubmit="return false;" style="display:block">
		<label> <? echo utf8ToHtml("Aten&ccedil;&atilde;o ao solicitar a execu&ccedil;&atilde;o da concilia&ccedil;&atilde;o.") ?> </label>
		<br style="clear:both" />
		<label> <? echo utf8ToHtml("A rotina executa automaticamente todos os dias &agraves 09:30.") ?> </label>
		<br style="clear:both" />
		<label> <? echo utf8ToHtml("Caso ocorra atraso para finalizar o processo batch da AILOS, a rotina aguarda o processo terminar.") ?> </label>
		<br style="clear:both" />
		<label> <? echo utf8ToHtml("Caso sejam solicitadas m&uacute;ltiplas execu&ccedil;&otilde;es, ser&atilde;o gerados m&uacute;ltiplos arquivos.") ?> </label>
		<br style="clear:both" />
		<label> <? echo utf8ToHtml("Utilizar somente quando ocorrer atraso na entrega dos arquivos por parte do Bancoob.") ?> </label>
		<br style="clear:both" />
		<br style="clear:both" />
	</form>
</div>