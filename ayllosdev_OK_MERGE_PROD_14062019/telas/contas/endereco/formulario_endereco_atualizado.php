<? 
/*!
 * FONTE        : formulario_endereco_atualizado.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Maio/2010 
 * OBJETIVO     : Formulário da rotina ENDEREÇO da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [05/07/2011] Henrique Pettenuci       Adicionado os campos nrdoapto e cddbloco.
 */	
?>
<form name="frmEndereco" id="frmEndereco" class="formulario">
	<fieldset>
	<legend align='center' style='font-size:13px;font-weight:bold;'><?echo utf8ToHtml('Endereço atual');?></legend>
		
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($endereco,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="dsendere"><? echo utf8ToHtml('Rua:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($endereco,'dsendere') ?>" />		
		
		<label for="nrendere"><? echo utf8ToHtml('Nr:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($endereco,'nrendere') ?>" />
		<br />
		
		<label for="complend"><? echo utf8ToHtml('Compl.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($endereco,'complend') ?>" />
		
		<label for="nrdoapto"><? echo utf8ToHtml('Apto.:') ?></label>
		<input name="nrdoapto" id="nrdoapto" type="text" value="<? echo getByTagName($endereco,'nrdoapto') ?>" />
		
		<label for="cddbloco"><? echo utf8ToHtml('Bloco:') ?></label>
		<input name="cddbloco" id="cddbloco" type="text" value="<? echo getByTagName($endereco,'cddbloco') ?>" />
		<br />
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($endereco,'nmbairro') ?>" />								
		
		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" value="<? echo getByTagName($endereco,'nrcxapst') ?>" />		
		<br />	
		
		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($endereco,'nmcidade') ?>" />
		
		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($endereco,'cdufende'), 1); ?>	
		<br/>

		<label for="idorigem"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="idorigem" name="idorigem">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($endereco,'idorigem') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($endereco,'idorigem') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($endereco,'idorigem') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>
	</fieldset>
	
	<fieldset>
	<legend align='center' style='font-size:13px;font-weight:bold;'><?echo utf8ToHtml('Novo endereço ( alterado pela internet )');?></legend>

		<label for="ib_nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="ib_nrcepend" id="ib_nrcepend" type="text" value="<? echo getByTagName($enderecoA,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="ib_dsendere"><? echo utf8ToHtml('Rua:') ?></label>
		<input name="ib_dsendere" id="ib_dsendere" type="text" value="<? echo getByTagName($enderecoA,'dsendere') ?>" />		
		
		<label for="ib_nrendere"><? echo utf8ToHtml('Nr:') ?></label>
		<input name="ib_nrendere" id="ib_nrendere" type="text" value="<? echo getByTagName($enderecoA,'nrendere') ?>" />
		<br />
		
		<label for="ib_complend"><? echo utf8ToHtml('Compl.:') ?></label>
		<input name="ib_complend" id="ib_complend" type="text" value="<? echo getByTagName($enderecoA,'complend') ?>" />
		
		<label for="ib_nrdoapto"><? echo utf8ToHtml('Apto.:') ?></label>
		<input name="ib_nrdoapto" id="ib_nrdoapto" type="text" value="<? echo getByTagName($enderecoA,'nrdoapto') ?>" />
		
		<label for="ib_cddbloco"><? echo utf8ToHtml('Bloco:') ?></label>
		<input name="ib_cddbloco" id="ib_cddbloco" type="text" value="<? echo getByTagName($enderecoA,'cddbloco') ?>" />
		<br />
		
		<label for="ib_nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="ib_nmbairro" id="ib_nmbairro" type="text" value="<? echo getByTagName($enderecoA,'nmbairro') ?>" />								
		
		<label for="ib_nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="ib_nrcxapst" id="ib_nrcxapst" type="text" value="<? echo getByTagName($enderecoA,'nrcxapst') ?>" />		
		<br />	
		
		<label for="ib_nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="ib_nmcidade" id="ib_nmcidade" type="text"  value="<? echo getByTagName($enderecoA,'nmcidade') ?>" />
		
		<label for="ib_cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($enderecoA,'cdufende'), 1); ?>	
		<br/>

		<label for="ib_idorigem"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="ib_idorigem" name="ib_idorigem">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($enderecoA,'idorigem') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($enderecoA,'idorigem') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($enderecoA,'idorigem') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>
	</fieldset>
</form>
