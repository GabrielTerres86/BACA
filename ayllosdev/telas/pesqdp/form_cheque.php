<?php
/*!
 * FONTE        : form_cheque.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Formlario nome do arquivo
 * --------------
 * ALTERAÇÕES   :
 *				  30/05/2019 - Adicionado campo vlracerto P565 (Jackson Barcellos AMcom)
 * --------------
 */ 
?>

	<form id="frmCheque" name="frmCheque" class="formulario">
		<div id="divCheque" >

			<label for="cdcmpchq"><? echo utf8ToHtml('Compe:') ?></label>
			<input id="cdcmpchq" name="cdcmpchq" type="text"/>
			
			<label for="cdbccxlt"><? echo utf8ToHtml('Banco:') ?></label>
			<input id="cdbccxlt" name="cdbccxlt" type="text"/>
			
			<label for="cdagechq"><? echo utf8ToHtml('Agencia:') ?></label>
			<input id="cdagechq" name="cdagechq" type="text"/>
			
			<label for="nrcheque"><? echo utf8ToHtml('Cheque:') ?></label>
			<input id="nrcheque" name="nrcheque" type="text"/>
			
			<br style="clear:both" />
			
			<label for="nrctachq"><? echo utf8ToHtml('Conta:') ?></label>
			<input id="nrctachq" name="nrctachq" type="text"/>
			
			<label for="vlcheque"><? echo utf8ToHtml('Valor:') ?></label>
			<input id="vlcheque" name="vlcheque" type="text"/>
			<label for="vlacerto"><? echo utf8ToHtml('Valor do Acerto:') ?></label>
			<input id="vlacerto" name="vlacerto" type="text"/>
			
			<br style="clear:both" />	
					
			<label for="dsdocmc7"><? echo utf8ToHtml('CMC-7:') ?></label>
			<input id="dsdocmc7" name="dsdocmc7" type="text"/>	
			
			<label for="dsbccxlt"><? echo utf8ToHtml('Capturado:') ?></label>
			<input id="dsbccxlt" name="dsbccxlt" type="text"/>

			
			<br style="clear:both" />
		</div>
	</form>
	</fieldset>
</form>
