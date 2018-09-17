<? 
/*!
 * FONTE        : form_aliencacao.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 30/03/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 */	
 ?>

<form name="frmAlienacao" id="frmAlienacao" class="formulario">	

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
	
	<label for="dsbemfin"><? echo utf8ToHtml('Descrição:') ?></label>
	<input name="dsbemfin" id="dsbemfin" type="text" value="" />
	
	<label for="tpchassi">Tipo Chassi:</label>
	<input name="tpchassi" id="tpchassi" type="text" value="" />
	<br />
	
	<label for="dscorbem">Cor/Classe:</label>
	<input name="dscorbem" id="dscorbem" type="text" value="" />
	<br />
	
	<label for="ufdplaca">UF/Placa:</label>
	<input name="ufdplaca" id="ufdplaca" type="text" value="" />
	<input name="nrdplaca" id="nrdplaca" type="text" value="" />
	
	<label for="dschassi">Chassi/N.Serie:</label>
	<input name="dschassi" id="dschassi" type="text" value="" />
	<br />
	
	<label for="nrrenava">RENAVAN:</label>
	<input name="nrrenava" id="nrrenava" type="text" value="" />
	
	<label for="uflicenc">UF Licenciamento:</label>
	<? echo selectEstado('uflicenc', 'SC', 1) ?>
			
	<label for="nranobem">Ano Fab.:</label>
	<input name="nranobem" id="nranobem" type="text" value="" />
	<br />
	
	<label for="nrmodbem">Ano Mod.:</label>
	<input name="nrmodbem" id="nrmodbem" type="text" value="" />
		
	<label for="nrcpfbem">CPF/CNPJ Propr.:</label>
	<input name="nrcpfbem" id="nrcpfbem" type="text" value="" />
	<br />
		
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_ALIENACAO') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_ALIENACAO'); return false;" />
	<? } ?>
</div>