<?
/*!
 * FONTE        : form_acaojud.php
 * CRIA��O      : Guilherme / SUPERO
 * DATA CRIA��O : 23/04/2013
 * OBJETIVO     : Mostrar campos da opcao B - Bloqueio
 * --------------
 * ALTERA��ES   :
 * --------------
 */

?>
<div id="divAcaojud" style='display:none;'>
<form id="frmAcaojud" name="frmAcaojud" class="formulario" onsubmit="return false;">

    <fieldset>
		<legend><? echo utf8ToHtml('Dados Judiciais'); ?></legend>

        <label for="nroficio">N�mero do Of�cio:</label>
        <input id="nroficio" name="nroficio" type="text" maxlength="25"  />
        <br/>

        <label for="nrproces">N�mero do Processo:</label>
        <input id="nrproces" name="nrproces" type="text" maxlength="25"   />
        <br/>

        <label for="dsjuizem">Ju�zo Emissor:</label>
        <input id="dsjuizem" name="dsjuizem" type="text" maxlength="70"  />
        <br/>

        <label for="dsresord">Resumo da Ordem:</label>
        <input id="dsresord" name="dsresord" type="text" maxlength="70"  />
        <br/>
        
        <label for="dtenvres">Data Envio Resposta:</label>
        <input id="dtenvres" name="dtenvres" type="text" maxlength="12" />
		<br />
		
		<label for="dsinfadc">Inf. Adicionais:</label>
        <input id="dsinfadc" name="dsinfadc" type="text" maxlength="70" />	
		<br />
		
        <label for="vlbloque">Valor a Bloquear/Transferir:</label>
        <input id="vlbloque" name="vlbloque" type="text" maxlength="20" />
		
		<label for="flblcrft">Bloquear Cr�ditos Futuros ?</label>
        <input id="flblcrft" name="flblcrft" type="checkbox"  />        
		
    </fieldset>
	<br style="clear:both;" />
		
</form>
   
</div>
<div id="div_tabblqjud"></div>
