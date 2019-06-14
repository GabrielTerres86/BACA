<? 
/*!
 * FONTE        : form_hipoteca.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 *
 * ALTERACOES   : 000: [23/11/2018] Alterado layout para ficar igual da criação da proposta - PRJ 438 (Mateus Z / Mouts) 
 */	
 ?>

<form name="frmHipoteca" id="frmHipoteca" class="formulario">	

	<fieldset>
		<legend><? echo utf8ToHtml('Dados da Alienação') ?></legend>

		<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
		<label id="lsbemfin"></label>
		<br />
			

		<label for="dsclassi"><? echo utf8ToHtml('Classificação:'); ?></label>
		<select id="dsclassi" name="dsclassi">
			<option value="RESIDENCIAL"> Residencial </option>
			<option value="COMERCIAL"> Comercial </option>
			<option value="VERANEIO"> Veraneio (Lazer) </option>
		</select>
					
		<label for="vlareuti"><? echo utf8ToHtml('Area útil:') ?></label>
		<input name="vlareuti" id="vlareuti" type="text" value=""/>

		<label for="dscatbem">Categoria:</label>
		<select name="dscatbem" id="dscatbem"></select>

		<label for="vlaretot"><? echo utf8ToHtml('Area total:') ?></label>
		<input name="vlaretot" id="vlaretot" type="text" value=""/>
					
		<label for="vlmerbem">Valor Mercado:</label>
		<input name="vlmerbem" id="vlmerbem" type="text" value="" />

		<label for="nrmatric"><? echo utf8ToHtml('Matrícula:') ?></label>
		<input name="nrmatric" id="nrmatric" type="text" value=""/>

        <label for="vlrdobem">Valor Venda:</label>
		<input name="vlrdobem" id="vlrdobem" type="text" value="" />
		
		<label for="dsbemfin">Descricao:</label>
		<input name="dsbemfin" id="dsbemfin" type="text" value="" />
        
        <fieldset><legend><? echo utf8ToHtml('Endereço') ?></legend>

			<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
			<input name="nrcepend" id="nrcepend" type="text" value=""/>
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>     

		    <label for="dsendere"><? echo utf8ToHtml('Rua:') ?></label>
			<input name="dsendere" id="dsendere" type="text" value=""/>		
			<br>

			<label for="nrendere"><? echo utf8ToHtml('Nr:') ?></label>
			<input name="nrendere" id="nrendere" type="text" value=""/>

	        <label for="dscompend"><? echo utf8ToHtml('Compl.:') ?></label>
			<input name="dscompend" id="dscompend" type="text" value=""/>	
			<br>			

			<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
			<input name="nmbairro" id="nmbairro" type="text" value=""/>								
			<br>			

			<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
			<input name="nmcidade" id="nmcidade" type="text" value=""/>	

		    <label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
			<? echo selectEstado('cdufende', getByTagName($endereco,'cdufende'), 1); ?>	
		</fieldset>
	</fieldset>
		
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_HIPOTECA') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_HIPOTECA'); return false;" />
	<? } ?>
</div>