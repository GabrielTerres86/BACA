<?php
/* 
 * FONTE        : form_tab049.php
 * CRIAÇÃO      : Márcio(Mouts)
 * DATA CRIAÇÃO : 08/2018
 * OBJETIVO     : Formulário de exibição da tela TAB049
  */
?>

<form name="frmTab049" id="frmTab049" class="formulario" style="display:block;">	
    <br style="clear:both" />
	<input type="hidden" id="dsdepart" name="dsdepart" value="<?php echo $glbvars["dsdepart"]; ?>" />
    <input type="hidden" id="idctrlab" name="idctrlaba" value="COOPER" />

	<fieldset>
		<legend>Par&acirc;metros Seguro Prestamista</legend>
		
		<label for="valormin" class='labelPri'>Valor m&iacute;nimo:</label>
		<input type="text" id="valormin" name="valormin" class="moeda" value="<?php echo $valormin == 0 ? '' : $valormin ?>" style="text-align:right;"/>
		<br style="clear:both" />

		<label for="valormax" class='labelPri'>Valor m&aacute;ximo:</label>
		<input type="text" id="valormax" name="valormax" class="moeda" value="<?php echo $valormax == 0 ? '' : $valormax ?>" style="text-align:right;"/>
		<br style="clear:both" />

		<label for="datadvig" class='labelPri' style='text-align:right;'>Data In&iacute;cio da Vig&ecirc;ncia:</label>
		<input name="datadvig" id="datadvig" type="text" class="data" value="" maxlength="10">
		<br style="clear:both" />
		
		<label for="pgtosegu" class='labelPri'>Pagamento Seguradora:</label>
		<input type="text" id="pgtosegu" name="pgtosegu" value="<?php echo $pgtosegu == 0 ? '' : $pgtosegu ?>" maxlength="7" style="text-align:right;"/>	
		<br style="clear:both" />

		<label for="vallidps" class='labelPri'>Valor Limite para Impress&atilde;o DPS:</label>
		<input type="text" id="vallidps" name="vallidps" class="moeda" value="<?php echo $vallidps == 0 ? '' : $vallidps ?>" style="text-align:right;"/>
		<br style="clear:both" />
    </fieldset>
	
	<fieldset>
		<legend>Par&acirc;metros Seguro Casa(CHUBB)</legend>

		<label for="subestip" class='labelPri' style='text-align:right;'>Subestipulante:</label>
		<input name="subestip" id="subestip" type="text" class="campo" value="" maxlength="25">
		<br style="clear:both" />
		
		<label for="sglarqui" class='labelPri' style='text-align:right;'>Sigla do Arquivo:</label>
		<input name="sglarqui" id="sglarqui" type="text" class="campo" value="" maxlength="2">
		<br style="clear:both" />
		
		<label for="nrsequen" class='labelPri' style='text-align:right;'>Sequencia:</label>
		<input type="text" id="nrsequen" name="nrsequen" value="<?php echo $nrsequen == 0 ? '' : $nrsequen ?>" maxlength="5" style="text-align:right;"/>			
		<br style="clear:both" />
	</fieldset>
	
</form>
