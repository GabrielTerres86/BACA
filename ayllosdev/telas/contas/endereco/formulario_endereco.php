<? 
/*!
 * FONTE        : formulario_endereco.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Maio/2010 
 * OBJETIVO     : Formulário da rotina ENDEREÇO da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001: [05/07/2011] Henrique Pettenuci - Adicionado os campos nrdoapto e cddbloco.
 * 002: [04/08/2015] Gabriel (Rkam)	    - Reformulacao cadastral.
 * 003: [15/09/2017] Alterações referente a melhoria 339 (Kelvin).
 * 004: [27/09/2017] Kelvin  (CECRED)	- Removido campos nrdoapto, cddbloco e nrcxapst (PRJ339).
 * 005: [15/03/2019] Anderson (SUPERO)  - Implementado titulo dinamico Comercial/Residencial (PJ429).
 */	 
?>
<form name="frmEndereco" id="frmEndereco" class="formulario">

	<fieldset name="fieldResidencial" id="fieldResidencial">
	
		<legend> <?php if ($inpessoa == 2) { echo 'Comercial'; }
		          else if ($inpessoa == 1) { echo 'Residencial'; } ?></legend>

		<label for="incasprp"><? echo utf8ToHtml(' Tipo do Imóvel:') ?></label>
		<select name="incasprp" id="incasprp" >
			<option value="" selected> - </option>
		</select>
		
		<label id="valor" for="vlalugue"><? echo (getByTagName($endereco,'incasprp') == 3) ? 'Aluguel:' : 'Valor:' ?></label>
		<input name="vlalugue" id="vlalugue" type="text" value="<? echo getByTagName($endereco,'vlalugue') ?>" />		
		<br />
		
		<label for="vlprebem"><? echo utf8ToHtml('Vl. Parc.:');?></label>
		<input name="vlprebem" id="vlprebem" type="text" value="<? echo getByTagName($endereco,'vlprebem') ?>" />
		
		<label for="qtprebem"><? echo utf8ToHtml('Qt. Parc.:');?></label>
		<input name="qtprebem" id="qtprebem" type="text" value="<? echo getByTagName($endereco,'qtprebem') ?>" />	
		<br/>
		
		<label for="dtinires"><? echo utf8ToHtml('Início de Residência:');?></label>
		<input name="dtinires" id="dtinires" type="text" value="<? echo getByTagName($endereco,'dtinires') ?>" />
		
		<label for="nranores"><? echo utf8ToHtml('Tempo Residência:');?></label>
		<input name="nranores" id="nranores" type="text" value="<? echo getByTagName($endereco,'nranores') ?>" />
		<br /> <br style="clear:both" />
		
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
			
		<br />
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($endereco,'nmbairro') ?>" />								
		
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
		
		<br style="clear:both" />
	
	</fieldset>
	
	<fieldset name="fieldCorrespondencia" id="fieldCorrespondencia">
	
		<legend> <? echo utf8ToHtml('Correspondência') ?> </legend>
		
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($enderecoCorrespondencia,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="dsendere"><? echo utf8ToHtml('Rua:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($enderecoCorrespondencia,'dsendere') ?>" />		
		
		<label for="nrendere"><? echo utf8ToHtml('Nr:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($enderecoCorrespondencia,'nrendere') ?>" />
		<br />
		
		<label for="complend"><? echo utf8ToHtml('Compl.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($enderecoCorrespondencia,'complend') ?>" />
			
		<br />
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($enderecoCorrespondencia,'nmbairro') ?>" />								
		
		<br />	
		
		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($enderecoCorrespondencia,'nmcidade') ?>" />
		
		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($enderecoCorrespondencia,'cdufende'), 1); ?>	
		<br/>

		<label for="idorigem"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="idorigem" name="idorigem">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($enderecoCorrespondencia,'idorigem') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($enderecoCorrespondencia,'idorigem') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($enderecoCorrespondencia,'idorigem') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>

		<br style="clear:both" />
	
	</fieldset>
	
	<fieldset name="fieldComplementar" id="fieldComplementar">
	
		<legend> Complementar </legend>
		
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($enderecoComplementar,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="dsendere"><? echo utf8ToHtml('Rua:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($enderecoComplementar,'dsendere') ?>" />		
		
		<label for="nrendere"><? echo utf8ToHtml('Nr:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($enderecoComplementar,'nrendere') ?>" />
		<br />
		
		<label for="complend"><? echo utf8ToHtml('Compl.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($enderecoComplementar,'complend') ?>" />
			
		<br />
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($enderecoComplementar,'nmbairro') ?>" />								
		
		<br />	
		
		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($enderecoComplementar,'nmcidade') ?>" />
		
		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($enderecoComplementar,'cdufende'), 1); ?>	
		<br/>

		<label for="idorigem"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="idorigem" name="idorigem">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($enderecoComplementar,'idorigem') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($enderecoComplementar,'idorigem') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($enderecoComplementar,'idorigem') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>

		<br style="clear:both" />

	</fieldset>
</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','FA','FAE','FEI','')) ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('EA')" /> 
	<? } else if ( $operacao == 'CA' && $flgcadas != 'M') { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV')" />
	<? } else if ( $operacao == 'SC' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltarRotina();" />		
	<? } ?>
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />

</div>
