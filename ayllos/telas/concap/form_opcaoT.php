<?php 
/*!
 * FONTE      : form_opcaoT.php                                        
 * AUTOR      : Lucas R                                                   
 * DATA       : Novembro/2013                																  
 * OBJETIVO   : Informar consulta de dados informados.                     
 *--------------------
 * ALTERACÇÕES:    
 * 001: 29/01/2014 - Alterar label dos campos indicando que são informações do dia (David)
 *--------------------											   
 */		
 
?>

<div id="divOpcaoT" style="display:none;"  >
<form id="frmOpcaoT" class="formulario" name="frmOpcaoT">

	<fieldset>
		<legend>Dados consultados</legend>
		
		<label for="vltotapl">Total de aplicações do dia</label>
		<input id="vltotapl" name="vltotapl" type="text" value="<? echo $vltotapl ?>"/>
					
		<label for="vltotrgt">Total de resgates do dia</label>
		<input id="vltotrgt" name="vltotrgt" type="text" value="<? echo $vltotrgt ?>"/>
		<br />
		<label for="vlcapliq">Captação líquida do dia</label>
		<input id="vlcapliq" name="vlcapliq" type="text" value="<? echo $vlcapliq ?>"/>	
	</fieldset> 
	
	
</form>
</div>
<div id="div_tabOpcaoT"></div>

