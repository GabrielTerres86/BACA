<?
/*!
 * FONTE        : form_desbloqueio.php
 * CRIA��O      : Lucas R.
 * DATA CRIA��O : Agosto/2013
 * OBJETIVO     : Mostrar campos do desbloqueio Judicial
 * --------------
 * ALTERA��ES   :
 * --------------
 */

?>
<div id="divDesbloqueio" style='display:none;'>
<form id="frmDesbloqueio" name="frmDesbloqueio" class="formulario" onsubmit="return false;">

    <fieldset>
		<legend>Dados Judiciais - Of�cio Desbloqueio</legend>

        <label for="nrofides">N�mero do Of�cio Desbloqueio:</label>
        <input id="nrofides" name="nrofides" type="text" maxlength="25"  />
        <br/>
            
        <label for="dtenvdes">Data Envio Resposta Desbloqueio:</label>
        <input id="dtenvdes" name="dtenvdes" type="text" maxlength="12" />
		<br />
		
		<label for="dsinfdes">Inf. Adicionais Desbloqueio:</label>
        <input id="dsinfdes" name="dsinfdes" type="text" maxlength="70" />	
		<br />
		
		<label for="fldestrf">Desbloqueio para Transfer�ncia:</label>
		<input name="fldestrf" id="flgsim" type="radio" class="radio" value="1" onClick="check();"  />	
		<label for="flgsim" class="radio">Sim</label>	
		<input name="fldestrf" id="flgnao" type="radio" class="radio" value="2" onClick="uncheck();"  />	
		<label for="flgnao" class="radio">N�o</label>	
				
    </fieldset>	
</form>
 
</div>
