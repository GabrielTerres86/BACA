<?
/*!
 * FONTE        : form_desbloqueio.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Mostrar campos do desbloqueio Judicial
 * --------------
 * ALTERAÇÕES   : 29/09/2017 - Melhoria 460 - (Andrey Formigari - Mouts)
 * --------------
 */

?>
<div id="divDesbloqueio" style='display:none;'>
	<form id="frmDesbloqueio" name="frmDesbloqueio" class="formulario" onsubmit="return false;">
		<fieldset>
			<legend>Dados Judiciais - Ofício Desbloqueio</legend>

			<label for="nrofides">Número do Ofício Desbloqueio:</label>
			<input id="nrofides" name="nrofides" type="text" maxlength="25"  />
			<br/>
            
			<label for="dtenvdes">Data Envio Resposta Desbloqueio:</label>
			<input id="dtenvdes" name="dtenvdes" type="text" maxlength="12" />
			<br />
		
			<label for="dsinfdes">Inf. Adicionais Desbloqueio:</label>
			<input id="dsinfdes" name="dsinfdes" type="text" maxlength="70" />	
			<br />
		
			<label for="fldestrf">Desbloqueio para Transferência:</label>
			<input name="fldestrf" id="flgsim" type="radio" class="radio" value="1" onClick="check();"  />	
			<label for="flgsim" class="radio">Sim</label>	
			<input name="fldestrf" id="flgnao" type="radio" class="radio" value="2" onClick="uncheck();"  />	
			<label for="flgnao" class="radio">Não</label>	

			<br />
			<label for="vldesblo">Valor do Desbloqueio:</label>
			<input id="vldesblo" name="vldesblo" class="moeda" type="text" maxlength="15" />
			<input id="vltmpbloque" name="vltmpbloque" type="hidden" />
				
		</fieldset>	
	</form>
</div>
