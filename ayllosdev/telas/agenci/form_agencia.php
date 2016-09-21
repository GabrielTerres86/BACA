<? 
/*!
 * FONTE        : form_agencia.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 04/02/2013
 * OBJETIVO     : Formulario de Agencias.
 * --------------
 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homolagação (Adriano)
 * --------------
 */	
?>

<form id="frmAgencia" name="frmAgencia" class="formulario">

	<fieldset id="frmConteudo">
	
		<legend><? echo utf8ToHtml('Ag&ecirc;ncias') ?></legend>
				
		<label for="cdageban">Agencia:</label>
		<input type="text" id="cdageban" name="cdageban" alt="Informe o numero da agencia." />
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(2);return false;"><img id="CdAgenc" name = "CdAgenc" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="dgagenci">Dig. Agencia:</label>
		<input type="text" id="dgagenci" name="dgagenci" alt="Informe o digito da agencia." />
		
		</br>
		
		<label for="nmageban">Nome:</label>
		<input type="text" id="nmageban" name="nmageban" alt="Informe o nome da agencia." />
		
		</br>
		
		<label for="cdsitagb">Ativa:</label>
		<select id="cdsitagb" name="cdsitagb" style="width:50px;">
			<option value="S"> Sim </option> 
			<option value="N"> N&atilde;o </option>
		</select>
		
		<label for="cdcompen">Cod. Compensacao:</label>
		<input type="text" id="cdcompen" name="cdcompen" alt="Informe o codigo de compensacao." />
		
		</br>
		
		<label for="nmcidade">Cidade:</label>
		<input type="text" id="nmcidade" name="nmcidade" alt="Informe o codigo da cidade." />
		
		<label for="cdufresd">UF:</label>
		<input type="text" id="cdufresd" name="cdufresd" alt="Informe o estado." />
		
	</fieldset>	
				
</form>



