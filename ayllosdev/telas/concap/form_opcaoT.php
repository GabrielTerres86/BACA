<?php 
/*!
 * FONTE      : form_opcaoT.php                                        
 * AUTOR      : Lucas R                                                   
 * DATA       : Novembro/2013                																  
 * OBJETIVO   : Informar consulta de dados informados.                     
 *--------------------
 * ALTERAC��ES:    
 * 001: 29/01/2014 - Alterar label dos campos indicando que s�o informa��es do dia (David)
 *--------------------											   
 */		
 
?>

<div id="divOpcaoT" style="display:none;"  >
<form id="frmOpcaoT" class="formulario" name="frmOpcaoT">

	<fieldset>
		<legend>Dados consultados</legend>
		
		<label for="vltotapl">Total de aplica��es do dia</label>
		<input id="vltotapl" name="vltotapl" type="text" value="<? echo $vltotapl ?>"/>
					
		<label for="vltotrgt">Total de resgates do dia</label>
		<input id="vltotrgt" name="vltotrgt" type="text" value="<? echo $vltotrgt ?>"/>
		<br />
		<label for="vlcapliq">Capta��o l�quida do dia</label>
		<input id="vlcapliq" name="vlcapliq" type="text" value="<? echo $vlcapliq ?>"/>	
	</fieldset> 
	
	
</form>
</div>
<div id="div_tabOpcaoT"></div>

