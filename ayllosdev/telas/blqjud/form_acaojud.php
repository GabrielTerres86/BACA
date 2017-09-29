<?
/*!
 * FONTE        : form_acaojud.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 23/04/2013
 * OBJETIVO     : Mostrar campos da opcao B - Bloqueio
 * --------------
 * ALTERAÇÕES   : Melhoria 339 - Andrey Formigari (Mouts)
 * --------------
 */

?>
<div id="divAcaojud" style='display:none;'>
<form id="frmAcaojud" name="frmAcaojud" class="formulario" onsubmit="return false;">

    <fieldset>
		<legend><? echo utf8ToHtml('Dados Judiciais'); ?></legend>

        <label for="nroficio">Número do Ofício:</label>
        <input id="nroficio" name="nroficio" type="text" maxlength="25"  />
        <br/>

        <label for="nrproces">Número do Processo:</label>
        <input id="nrproces" name="nrproces" type="text" maxlength="25"   />
        <br/>

        <label for="dsjuizem">Juízo Emissor:</label>
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
		
		<label for="flblcrft">Bloquear Créditos Futuros ?</label>
        <input id="flblcrft" name="flblcrft" type="checkbox"  />                
		<input id="cdmodali" name="cdmodali" type="hidden"  />
		
    </fieldset>
</form>
   
</div>

