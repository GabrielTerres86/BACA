<?php 
/*!
 * FONTE      : form_operacao.php                                        
 * AUTOR      : Lucas R                                                   
 * DATA       : Novembro/2013                																  
 * OBJETIVO   : Informar parametros para impressao da tela CONCAP                     
 *--------------------
 * ALTERACÇÕES:    
 * 001: 29/01/2014 - Incluir opção para carregar resgates futuros e alterar label "Resgates cadastrados" para "Resgates do dia" (David)
 *--------------------											   
 */		
 
	
	
?>

<div id="divOperacao" style="display:none;"  >
<form id="frmOperacao" class="formulario" name="frmOperacao">

	<fieldset>
		<legend>Dados para consulta/impressão</legend>
		
		<label for="cdagenci" >PA:</label>
		<input id="cdagenci" name="cdagenci" type="text" value=""/>
					
		<label for="dtmvtolt">Movimento:</label>
		<input id="dtmvtolt" name="dtmvtolt" type="text" value="<? echo $glbvars["dtmvtolt"]; ?>" />
		
	    <label for="opcaoimp"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
		<select id="opcaoimp" name="opcaoimp">
			<option value="A" <? echo $opcaoimp == 'A' ? 'selected' : '' ?> > A - <? echo utf8ToHtml('Aplica&ccedil;&otilde;es cadastradas') ?></option>
			<option value="R" <? echo $opcaoimp == 'R' ? 'selected' : '' ?> > R - <? echo utf8ToHtml('Resgates do dia') ?></option>
			<option value="F" <? echo $opcaoimp == 'F' ? 'selected' : '' ?> > F - <? echo utf8ToHtml('Resgates futuros') ?></option>
		</select>
			
	</fieldset> 
	
	
</form>
</div>

