<? 
 /*!
 * FONTE        : form_tipo6.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Formulário de exibição do TIPO 6 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 *
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('6 - Interveniente Garantidor Veículo') ?></legend>
	
	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão do Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />
	<br />
	
	<label for="nmdgaran"><? echo utf8ToHtml('Nome do Interv. Garantidor:') ?></label>
	<input type="text" id="nmdgaran" name="nmdgaran" value="<? echo getByTagName($dados,'nmdgaran')?>" />
	<br />

	<label for="nrcpfgar"><? echo utf8ToHtml('CPF Interv. Garantidor:') ?></label>
	<input type="text" id="nrcpfgar" name="nrcpfgar" value="<? echo formatar(getByTagName($dados,'nrcpfgar'),'cpf')?>" />
	<br />

	<label for="nrdocgar"><? echo utf8ToHtml('Docto Interv. Garantidor:') ?></label>
	<input type="text" id="nrdocgar" name="nrdocgar" value="<? echo getByTagName($dados,'nrdocgar')?>" />
	<br />

	<label for="dsbemfin"><? echo utf8ToHtml('Automovel:') ?></label>
	<input type="text" id="dsbemfin" name="dsbemfin" value="<? echo getByTagName($dados,'dsbemfin')?>" />
	<br />

	<label for="nrrenava"><? echo utf8ToHtml('Renavan:') ?></label>
	<input type="text" id="nrrenava" name="nrrenava" value="<? echo mascara(getByTagName($dados,'nrrenava'),'###.###.###.###') ?>" />
	<br />

	<label for="tpchassi"><? echo utf8ToHtml('Tipo Chassi:') ?></label>
	<input type="text" id="tpchassi" name="tpchassi" value="<? echo getByTagName($dados,'tpchassi')?>" />

	<label for="dschassi"><? echo utf8ToHtml('Chassi:') ?></label>
	<input type="text" id="dschassi" name="dschassi" value="<? echo getByTagName($dados,'dschassi')?>" />
	<br />

	<label for="nrdplaca"><? echo utf8ToHtml('Placa:') ?></label>
	<input type="text" id="nrdplaca" name="nrdplaca" value="<? echo mascara(getByTagName($dados,'nrdplaca'),'#######') ?>" />
	<br />

	<label for="ufdplaca"><? echo utf8ToHtml('UF Placa:') ?></label>
	<input type="text" id="ufdplaca" name="ufdplaca" value="<? echo getByTagName($dados,'ufdplaca')?>" />
	<br />

	<label for="dscorbem"><? echo utf8ToHtml('Cor:') ?></label>
	<input type="text" id="dscorbem" name="dscorbem" value="<? echo getByTagName($dados,'dscorbem')?>" />
	<br />
	
	<label for="nranobem"><? echo utf8ToHtml('Ano:') ?></label>
	<input type="text" id="nranobem" name="nranobem" value="<? echo getByTagName($dados,'nranobem')?>" />

	<label for="nrmodbem"><? echo utf8ToHtml('Modelo:') ?></label>
	<input type="text" id="nrmodbem" name="nrmodbem" value="<? echo getByTagName($dados,'nrmodbem')?>" />

	<label for="uflicenc"><? echo utf8ToHtml('UF Licenci.:') ?></label>
	<input type="text" id="uflicenc" name="uflicenc" value="<? echo getByTagName($dados,'uflicenc')?>" />
	
	<br style="clear:both" />	

	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
formataTipo6();
</script>