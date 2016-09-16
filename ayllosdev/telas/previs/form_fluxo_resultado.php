<?
/*
 * FONTE        : form_fluxo_resultado.php
 * CRIAÇÃO      : Tiago Machado 
 * DATA CRIAÇÃO : 01/08/2012												ÚLTIMA ALTERAÇÃO: 27/09/2012
 * OBJETIVO     : form de resultados('R') da opcao fluxo na tela PREVIS.
 * --------------
 * ALTERAÇÕES   : 27/09/2012 - Ajuste referente ao projeto Fluxo Financeiro (Adriano).
 * --------------
 */
?>
	<fieldset id="fsetresultado" name="fsetresultado">
		<legend> <? echo utf8ToHtml('Resultado') ?> </legend>	
		
		<label for="vlentrad">ENTRADAS:</label>		
		<input name="vlentrad" id="vlentrad" type="text" value="<?php echo formataMoeda($vlentrad) ?>" />
		<label for="lbinvest">INVESTIMENTOS:</label>
		
		<br style="clear:both;"/>
		
		<label for="vlsaidas">SA&Iacute;DAS:</label>		
		<input name="vlsaidas" id="vlsaidas" type="text" value="<?php echo formataMoeda($vlsaidas) ?>" />
		<label for="vlresgat">RESGATE:</label>
		<input name="vlresgat" id="vlresgat" type="text" value="<?php echo formataMoeda($vlresgat) ?>" />
		

		<br style="clear:both;" />
		
		<label for="vlresult">RESULTADO CENTRALIZA&Ccedil;&Atilde;O:</label>		
		<input name="vlresult" id="vlresult" type="text" value="<?php echo formataMoeda($vlresult) ?>" />
		<label for="vlaplica">APLICA&Ccedil;&Atilde;O:</label>
		<input name="vlaplica" id="vlaplica" type="text" value="<?php echo formataMoeda($vlaplica) ?>" />

		<br style="clear:both;" />
		
		<label for="vlsldcta">SALDO C/C DIA ANTERIOR:</label>		
		<input name="vlsldcta" id="vlsldcta" type="text" value="<?php echo formataMoeda($vlsldcta) ?>" />

		<br style="clear:both;"/>		
		
		<label for="vlsldfin">SALDO FINAL C/C:</label>		
		<input name="vlsldfin" id="vlsldfin" type="text" value="<?php echo formataMoeda($vlsldfin) ?>" />

		<br style="clear:both;"/>
		
		<br  style="clear:both" /><br />
		
		<label for="nmoperad">Operador:</label>
		<input name="nmoperad" id="nmoperad" type="text" value="<?php echo $nmoperad ?>" />
		<label for="hrtransa"></label>
		<input name="hrtransa" id="hrtransa" type="text" value="<?php echo $hrtransa ?>" />
		
		
	</fieldset>		
