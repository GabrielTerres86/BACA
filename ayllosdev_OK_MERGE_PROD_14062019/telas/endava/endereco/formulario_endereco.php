<? 
/*!
 * FONTE        : formulario_endereco.php
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

	<label for="incasprp"><? echo utf8ToHtml(' Tipo do Imóvel:') ?></label>
	<select name="incasprp" id="incasprp" >
		<option value="" selected> - </option>
	</select>
	
	<label for="vlalugue"><? echo utf8ToHtml('Valor:') ?></label>
	<input name="vlalugue" id="vlalugue" type="text" value="<? echo getByTagName($endereco,'vlalugue') ?>" />		
	<br />
	
	<label for="dtinires"><? echo utf8ToHtml('Início de Residência:');?></label>
	<input name="dtinires" id="dtinires" type="text" value="<? echo getByTagName($endereco,'dtinires') ?>" />
	
	<label for="nranores"><? echo utf8ToHtml('Tempo Residência:');?></label>
	<input name="nranores" id="nranores" type="text" value="<? echo getByTagName($endereco,'nranores') ?>" />
	<br /> <br style="clear:both" />
	
	<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
	<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($endereco,'nrcepend') ?>" />
	<!--<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>-->
	
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
	
	<br style="clear:both" />

</form>

<div id="divBotoes">		
	<? if ( in_array($operacao,array('AC','FA','FAE','FEI','')) ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif"  onClick="controlaOperacao('EA')" />
	<? } else if ( $operacao == 'CA' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC')" />		
		<input type="image" id="btSalvar"  src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV')" />
	<? } else if ( $operacao == 'SC' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="fechaRotina(divRotina)" />
	<? }?>
</div>
