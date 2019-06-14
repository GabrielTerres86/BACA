<? 
 /*!
 * FONTE        : form_extppr.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011 
 * OBJETIVO     : Formulário de exibição do EXTPPR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmExtppr" id="frmExtppr" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> Dados do Extrato </legend>	

		<label for="nmprimtl">Titular:</label>
		<input name="nmprimtl" id="nmprimtl" type="text" />
			
		<br />	
		
		<label for="dtvctopp"><? echo utf8ToHtml('Data de Vcto:') ?></label>
		<input name="dtvctopp" id="dtvctopp" type="text" />
		
		<label for="dddebito"><? echo utf8ToHtml('Dia do Debito:') ?></label>
		<input name="dddebito" id="dddebito" type="text" />
		
		<label for="vlrdcapp"><? echo utf8ToHtml('Saldo Atual:') ?></label>
		<input name="vlrdcapp" id="vlrdcapp" type="text" />

		
	</fieldset>		


	
</form>