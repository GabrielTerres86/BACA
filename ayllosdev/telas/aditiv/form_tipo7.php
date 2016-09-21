<? 
 /*!
 * FONTE        : form_tipo7.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Formulário de exibição do TIPO 7 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('7 - Sub-rogação - C/ Nota Promissoria') ?></legend>

	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />

	<label for="nrcpfgar"><? echo utf8ToHtml('CPF do Avalista:') ?></label>	
	<input type="text" id="nrcpfgar" name="nrcpfgar" value="<? echo formatar(getByTagName($dados,'nrcpfgar'),'cpf')  ?>" />
	<br />
	</fieldset>	

	<fieldset>
	<legend><? echo utf8ToHtml('Nota Promissoria / Valor') ?></legend>
	
	<label for="quebrali"></label>	
	<input type="text" id="nrpromi1" name="nrpromi1" value="<? echo getByTagName($dados[29]->tags,'nrpromis.1') ?>" />
	<input type="text" id="vlpromi1" name="vlpromi1" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.1')) ?>" />

	<label for="espacos1"></label>	
	<input type="text" id="nrpromi2" name="nrpromi2" value="<? echo getByTagName($dados[29]->tags,'nrpromis.2') ?>" />
	<input type="text" id="vlpromi2" name="vlpromi2" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.2')) ?>" />
	<br />

	<input type="text" id="nrpromi3" name="nrpromi3" value="<? echo getByTagName($dados[29]->tags,'nrpromis.3') ?>" />
	<input type="text" id="vlpromi3" name="vlpromi3" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.3')) ?>" />

	<label for="espacos2"></label>	
	<input type="text" id="nrpromi4" name="nrpromi4" value="<? echo getByTagName($dados[29]->tags,'nrpromis.4') ?>" />
	<input type="text" id="vlpromi4" name="vlpromi4" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.4')) ?>" />
	<br />

	<input type="text" id="nrpromi5" name="nrpromi5" value="<? echo getByTagName($dados[29]->tags,'nrpromis.5') ?>" />
	<input type="text" id="vlpromi5" name="vlpromi5" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.5')) ?>" />

	<label for="espacos3"></label>	
	<input type="text" id="nrpromi6" name="nrpromi6" value="<? echo getByTagName($dados[29]->tags,'nrpromis.6') ?>" />
	<input type="text" id="vlpromi6" name="vlpromi6" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.6')) ?>" />
	<br />
	
	<input type="text" id="nrpromi7" name="nrpromi7" value="<? echo getByTagName($dados[29]->tags,'nrpromis.7') ?>" />
	<input type="text" id="vlpromi7" name="vlpromi7" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.7')) ?>" />

	<label for="espacos4"></label>	
	<input type="text" id="nrpromi8" name="nrpromi8" value="<? echo getByTagName($dados[29]->tags,'nrpromis.8') ?>" />
	<input type="text" id="vlpromi8" name="vlpromi8" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.8')) ?>" />
	<br />
	
	<input type="text" id="nrpromi9" name="nrpromi9" value="<? echo getByTagName($dados[29]->tags,'nrpromis.9') ?>" />
	<input type="text" id="vlpromi9" name="vlpromi9" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.9')) ?>" />

	<label for="espacos5"></label>	
	<input type="text" id="nrprom10" name="nrprom10" value="<? echo getByTagName($dados[29]->tags,'nrpromis.10') ?>" />
	<input type="text" id="vlprom10" name="vlprom10" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.10')) ?>" />
	
	<br style="clear:both" />
	
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
	formataTipo7();
</script>