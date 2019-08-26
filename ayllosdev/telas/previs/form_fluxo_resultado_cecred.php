<?
/*
 * FONTE        : form_fluxo_resultado_cecred.php
 * CRIAÇÃO      : Tiago Machado 
 * DATA CRIAÇÃO : 06/08/2012
 * OBJETIVO     : form de saida('R') da opcao fluxo na tela PREVIS da CENTRAL.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>


	<fieldset id="fsetresultadocecred" name="fsetresultadocecred">
		<legend> <? echo utf8ToHtml('Resultado') ?> </legend>	
		
		<label for="cdbcova1">COMPE085</label>
		<label for="cdbcova2">BANCO DO BRASIL</label>
		<label for="cdbcova3">BANCOOB</label>

		<br />
		
		<label for="vlentrad">ENTRADAS:</label>
		<label for="vlentrad1"></label>
		<input name="vlentrad1" id="vlentrad1" type="text" value="<?php echo formataMoeda(getByTagName($vlentrad,'vlentrad.1')) ?>" />
		<label for="vlentrad2"></label>
		<input name="vlentrad2" id="vlentrad2" type="text" value="<?php echo formataMoeda(getByTagName($vlentrad,'vlentrad.2')) ?>" />
		<label for="vlentrad3"></label>
		<input name="vlentrad3" id="vlentrad3" type="text" value="<?php echo formataMoeda(getByTagName($vlentrad,'vlentrad.3')) ?>" />

		<br />
		
		<label for="vlsaidas">SAIDAS:</label>
		<label for="vlsaidas1"></label>
		<input name="vlsaidas1" id="vlsaidas1" type="text" value="<?php echo formataMoeda(getByTagName($vlsaidas,'vlsaidas.1')) ?>" />
		<label for="vlsaidas2"></label>
		<input name="vlsaidas2" id="vlsaidas2" type="text" value="<?php echo formataMoeda(getByTagName($vlsaidas,'vlsaidas.2')) ?>" />
		<label for="vlsaidas3"></label>
		<input name="vlsaidas3" id="vlsaidas3" type="text" value="<?php echo formataMoeda(getByTagName($vlsaidas,'vlsaidas.3')) ?>" />


		<br style="clear:both" /><br />
		
		<label for="vlresult">RESULTADO:</label>
		<label for="vlresult1"></label>
		<input name="vlresult1" id="vlresult1" type="text" value="<?php echo formataMoeda(getByTagName($vlresult,'vlresult.1')) ?>" />
		<label for="vlresult2"></label>
		<input name="vlresult2" id="vlresult2" type="text" value="<?php echo formataMoeda(getByTagName($vlresult,'vlresult.2')) ?>" />
		<label for="vlresult3"></label>
		<input name="vlresult3" id="vlresult3" type="text" value="<?php echo formataMoeda(getByTagName($vlresult,'vlresult.3')) ?>" />
		
		
	</fieldset>		
