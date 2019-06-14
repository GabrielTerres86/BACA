<? 
 /*!
 * FONTE        : form_extcap.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/08/2011 
 * OBJETIVO     : Formulário de exibição do EXTCAP
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmExtcap" id="frmExtcap" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> Dados do Extrato </legend>	

		
		<label for="dtmovmto"><? echo utf8ToHtml('A Partir do Ano:') ?></label>
		<input name="dtmovmto" id="dtmovmto" type="text" value="<? echo $dtmovmto ?>" />
		
		<label for="vlsanter"><? echo utf8ToHtml('Saldo Anterior:') ?></label>
		<input name="vlsanter" id="vlsanter" type="text" value="<? echo formataMoeda($vlsldant) ?>" />

		
	</fieldset>		
	
</form>

