<? 
 /*!
 * FONTE        : form_extemp.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011 
 * OBJETIVO     : Formulário de exibição do EXTEMP
 * --------------
 * ALTERAÇÕES   : 19/11/2012 - Adicionado form formEmpres para impressao. (Jorge)
 * 
 *				  29/11/2012 - Alterado layout da tela e incluso ocultamento do
 *							   form ao carregar a tela (Daniel).
 *				 
 *				  06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714) 
 * --------------
 */	
?>
<form name="frmExtemp" id="frmExtemp" class="formulario" onSubmit="return false;" style="display:none" >	

	<fieldset>
		<legend> Dados do Extrato </legend>	
		<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
		<input name="nrctremp" id="nrctremp" type="text" autocomplete="off" style="width:85px !important;" />
		<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<label for="vlsdeved"><? echo utf8ToHtml('Saldo Devedor:') ?></label>
		<input name="vlsdeved" id="vlsdeved" type="text" style="width:105px !important;"/>
		
		<label for="vljuracu"><? echo utf8ToHtml('Juros:') ?></label>
		<input name="vljuracu" id="vljuracu" type="text" style="width:105px !important;"/>
		
		<br />
		
		<label for="vlemprst"><? echo utf8ToHtml('Emprestado:') ?></label>
		<input name="vlemprst" id="vlemprst" type="text" style="width:110px !important;"/>

		<label for="vlpreemp"><? echo utf8ToHtml('Parcelas:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" style="width:105px !important;" />

		<label for="dtdpagto"><? echo utf8ToHtml('Data Pgto:') ?></label>
		<input name="dtdpagto" id="dtdpagto" type="text" style="width:105px !important;"/>
		
	</fieldset>		
			
</form>
<form id="formEmpres" ></form>