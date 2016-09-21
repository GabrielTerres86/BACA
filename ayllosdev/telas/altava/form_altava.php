<? 
 /*!
 * FONTE        : form_altava.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/12/2011 
 * OBJETIVO     : Formulário de exibição do ALTAVA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmAltava" id="frmAltava" class="formulario" onSubmit="return false;" style="display:none" >	

	<fieldset>
		<legend> Dados do Contrato </legend>	
		
		<label for="dslcremp"><? echo utf8ToHtml('L. Credito:') ?></label>
		<input name="dslcremp" id="dslcremp" type="text" />
		
		<label for="dsfinemp"><? echo utf8ToHtml('Finalidade:') ?></label>
		<input name="dsfinemp" id="dsfinemp" type="text" />
		
		<br />
		
		<label for="vlemprst"><? echo utf8ToHtml('Emprestado:') ?></label>
		<input name="vlemprst" id="vlemprst" type="text" />

		<label for="vlpreemp"><? echo utf8ToHtml('Prestação:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" />

		<label for="qtpreemp"><? echo utf8ToHtml('Quantidade:') ?></label>
		<input name="qtpreemp" id="qtpreemp" type="text" />
		
	</fieldset>		
			
</form>