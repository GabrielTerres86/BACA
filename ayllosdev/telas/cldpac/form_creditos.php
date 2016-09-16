<?php
/*!
 * FONTE        	: form_cheque.php
 * CRIAÇÃO      	: Gabriel Capoia (DB1)
 * DATA CRIAÇÃO 	: 11/01/2013
 * OBJETIVO     	: Formlario nome do arquivo
 * ULTIMA ALTERAÇÃO : 08/07/2013
 * --------------	
 * ALTERAÇÕES   	: 08/07/2013 - Alterado para receber o novo padrão de layout do Ayllos Web. (Reinert)
 * --------------
 */ 
?>

<form id="frmCreditos" name="frmCreditos" class="formulario">
	<div id="divCreditos">
		<label for="cddjusti"><? echo utf8ToHtml('Justificativa:') ?></label>
		<input id="cddjusti" name="cddjusti" onChange="buscaJustificativa(); return false;" type="text"/>
	
		<label for="dsdjusti"><? echo utf8ToHtml('') ?></label>
		<input id="dsdjusti" name="dsdjusti" type="text"/>
		
		<br style="clear:both" />
	
		<label for="dsobserv"><? echo utf8ToHtml('Comp.Justi.:') ?></label>
		<input id="dsobserv" name="dsobserv" type="text"/>
	</div>
	
</form>
</fieldset>
</form>