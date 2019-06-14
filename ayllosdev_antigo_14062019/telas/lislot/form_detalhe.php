<?php
/*!
 * FONTE        : form_detalhe.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Formulario abaixo da tabela da Tela LISLOT
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<form id="frmDetalhe" name="frmDetalhe" class="formulario">
	<div id="divDetalhe" >
					
		<label for="totregis"><? echo utf8ToHtml('Quantidade de Registros:') ?></label>
		<input id="totregis" name="totregis" type="text"/>
			
		<label for="vllanmto"><? echo utf8ToHtml('Valor Total:') ?></label>
		<input id="vllanmto" name="vllanmto" type="text" class="moeda" />
						
		<br style="clear:both" />
				
	</div>
	</form>
	</fieldset>
</form>


