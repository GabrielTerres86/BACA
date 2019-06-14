<? 
 /*!
 * FONTE        : form_aliena.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/07/2011 
 * OBJETIVO     : Formulário de exibição do ALIENA
 * --------------
 * ALTERAÇÕES   : 21/11/2012 - Alterado botões do tipo tag <input> por
 *			      			   tag <a> (Daniel).
 * --------------
 */	
?>
<form name="frmAliena" id="frmAliena" class="formulario" onSubmit="return false;" style="display:none">	

	<fieldset>
		<legend> </legend>	
		<label for="dsaliena"><? echo utf8ToHtml('Bem/Garantia:') ?></label>
		<input name="dsaliena" id="dsaliena" type="text" />
		
		<br />
		
		<label for="flgalfid"><? echo utf8ToHtml('Alienação:') ?></label>
		<select name="flgalfid" id="flgalfid">
			<option value="yes"> Ok       </option>
			<option value="no"> Pendente </option>
		</select>
		
		<label for="dtvigseg"><? echo utf8ToHtml('Venc. Seg.:') ?></label>
		<input name="dtvigseg" id="dtvigseg" type="text" autocomplete="off"/>

		<label for="flglbseg"><? echo utf8ToHtml('Lib. Seg.:') ?></label>
		<select name="flglbseg" id="flglbseg">
			<option value="yes"> Sim  </option>
			<option value="no" >  <? echo utf8ToHtml('Não') ?> </option>
		</select>

		<label for="flgrgcar"><? echo utf8ToHtml('Reg. Cart.:') ?></label>
		<select name="flgrgcar" id="flgrgcar">
			<option value="yes"> Sim  </option>
			<option value="no" >  <? echo utf8ToHtml('Não') ?> </option>
		</select>
		<a href="#" class="botao" id="btnFormulario" name="btnFormulario">OK</a>
	</fieldset>	
	<br />

</form>