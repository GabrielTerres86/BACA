<?
/*
 * FONTE        : form_fluxo_entrada_cecred.php
 * CRIA��O      : Tiago Machado 
 * DATA CRIA��O : 06/08/2012												�LTIMA ALTERA��O: 21/03/2016
 * OBJETIVO     : form de entrada('E') da opcao fluxo na tela PREVIS para CENTRAL.
 * --------------
 * ALTERA��ES   : 25/09/2012 - Ajustes referente ao projeto Fluxo Financeiro (Adriano).
				  21/03/2016 - Ajuste layout, valores negativos (Adriano)
 * --------------
 */
?>


	<fieldset id="fsetentradacecred" name="fsetentradacecred">
	
		<legend> <? echo utf8ToHtml('Entradas') ?> </legend>	
		
		<label for="cdbcova1">COMPE085</label>
		<label for="cdbcova2">BANCO DO BRASIL</label>
		<label for="cdbcova3">BANCOOB</label>

		<br />
		
		<label for="vlmvtitg">MVTO. CONTA ITG:</label>
		<label for="vlmvtitg1"></label>
		<input name="vlmvtitg1" id="vlmvtitg1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlmvtitg,'vlmvtitg.1')),2,",","."); ?>" />
		<label for="vlmvtitg2"></label>
		<input name="vlmvtitg2" id="vlmvtitg2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlmvtitg,'vlmvtitg.2')),2,",","."); ?>" />
		<label for="vlmvtitg3"></label>
		<input name="vlmvtitg3" id="vlmvtitg3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlmvtitg,'vlmvtitg.3')),2,",","."); ?>" />

		<br />
		
		<label for="vlcheque">NR CHEQUES:</label>
		<label for="vlcheque1"></label>
		<input name="vlcheque1" id="vlcheque1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlcheque,'vlcheque.1')),2,",","."); ?>" />
		<label for="vlcheque2"></label>
		<input name="vlcheque2" id="vlcheque2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlcheque,'vlcheque.2')),2,",","."); ?>" />
		<label for="vlcheque3"></label>
		<input name="vlcheque3" id="vlcheque3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlcheque,'vlcheque.3')),2,",","."); ?>" />

		<br />
		
		<label for="vltotdoc">SR DOC:</label>
		<label for="vltotdoc1"></label>
		<input name="vltotdoc1" id="vltotdoc1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotdoc,'vltotdoc.1')),2,",","."); ?>" />
		<label for="vltotdoc2"></label>
		<input name="vltotdoc2" id="vltotdoc2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotdoc,'vltotdoc.2')),2,",","."); ?>" />
		<label for="vltotdoc3"></label>
		<input name="vltotdoc3" id="vltotdoc3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotdoc,'vltotdoc.3')),2,",","."); ?>" />

		<br />
		
		<label for="vltotted">SR TED:</label>
		<label for="vltotted1"></label>
		<input name="vltotted1" id="vltotted1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotted,'vltotted.1')),2,",","."); ?>" />
		<label for="vltotted2"></label>
		<input name="vltotted2" id="vltotted2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotted,'vltotted.2')),2,",","."); ?>" />
		<label for="vltotted3"></label>
		<input name="vltotted3" id="vltotted3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltotted,'vltotted.3')),2,",","."); ?>" />

		<br />
		
		<label for="vltottit">SR T&IacuteTULOS:</label>
		<label for="vltottit1"></label>
		<input name="vltottit1" id="vltottit1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltottit,'vltottit.1')),2,",","."); ?>" />
		<label for="vltottit2"></label>
		<input name="vltottit2" id="vltottit2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltottit,'vltottit.2')),2,",","."); ?>" />
		<label for="vltottit3"></label>
		<input name="vltottit3" id="vltottit3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vltottit,'vltottit.3')),2,",","."); ?>" />

		<br />
		
		<label for="vldevolu">DEV CHEQUE REMETIDO:</label>
		<label for="vldevolu1"></label>
		<input name="vldevolu1" id="vldevolu1" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.1')) ?>" />
		<label for="vldevolu2"></label>
		<input name="vldevolu2" id="vldevolu2" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.2')) ?>" />
		<label for="vldevolu3"></label>
		<input name="vldevolu3" id="vldevolu3" type="text" value="<?php echo formataMoeda(getByTagName($vldevolu,'vldevolu.3')) ?>" />

		<br />
		
		<label for="vlttinss">INSS:</label>
		<label for="vlttinss1"></label>
		<input name="vlttinss1" id="vlttinss1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttinss,'vlttinss.1')),2,",","."); ?>" />
		<label for="vlttinss2"></label>
		<input name="vlttinss2" id="vlttinss2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttinss,'vlttinss.2')),2,",","."); ?>" />
		<label for="vlttinss3"></label>
		<input name="vlttinss3" id="vlttinss3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttinss,'vlttinss.3')),2,",","."); ?>" />

		<br />
		
		<label for="vldivers">DIVERSOS:</label>
		<label for="vldivers1"></label>
		<input name="vldivers1" id="vldivers1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vldivers,'vldivers.1')),2,",","."); ?>" />
		<label for="vldivers2"></label>
		<input name="vldivers2" id="vldivers2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vldivers,'vldivers.2')),2,",","."); ?>" />
		<label for="vldivers3"></label>
		<input name="vldivers3" id="vldivers3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vldivers,'vldivers.3')),2,",","."); ?>" />

		<br style="clear:both" /><br />
		
		<label for="vlttcrdb">TOTAL CREDITO:</label>
		<label for="vlttcrdb1"></label>
		<input name="vlttcrdb1" id="vlttcrdb1" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttcrdb,'vlttcrdb.1')),2,",","."); ?>" />
		<label for="vlttcrdb2"></label>
		<input name="vlttcrdb2" id="vlttcrdb2" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttcrdb,'vlttcrdb.2')),2,",","."); ?>" />
		<label for="vlttcrdb3"></label>
		<input name="vlttcrdb3" id="vlttcrdb3" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($vlttcrdb,'vlttcrdb.3')),2,",","."); ?>" />
		
	</fieldset>		
