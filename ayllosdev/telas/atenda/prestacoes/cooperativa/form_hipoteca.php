<? 
/*!
 * FONTE        : form_hipoteca.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 */	
 ?>

<form name="frmHipoteca" id="frmHipoteca" class="formulario">	

	<fieldset>
		<legend><? echo utf8ToHtml('Dados para a  H I P O T E C A') ?></legend>

		<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
		<label id="lsbemfin"></label>
		<br />
			
		<label for="dscatbem">Categoria:</label>
		<select name="dscatbem" id="dscatbem">
			<option value=""> - </option>
		</select>
					
		<label for="vlmerbem">Valor de Mercado:</label>
		<input name="vlmerbem" id="vlmerbem" type="text" value="" />
		<br />
		
		<label for="dsbemfin">Descricao:</label>
		<input name="dsbemfin" id="dsbemfin" type="text" value="" />
		<br />
		
		<label for="dscorbem">Endereco:</label>
		<input name="dscorbem" id="dscorbem" type="text" value="" />
		<br />
	</fieldset>
		
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_HIPOTECA') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_HIPOTECA'); return false;" />
	<? } ?>
</div>