<? 
 /*!
 * FONTE        : form_tipo8.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Formulário de exibição do TIPO 8 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('8 - Sub-rogação - S/ Nota Promissoria') ?></legend>
	
	<label for="nrcpfgar"><? echo utf8ToHtml('CPF do Avalista:') ?></label>
	<input type="text" id="nrcpfgar" name="nrcpfgar" value="<? echo formatar(getByTagName($dados,'nrcpfgar'),'cpf')?>" />
	<br />

	<label for="vlpromis"><? echo utf8ToHtml('Valor Pago:') ?></label>	
	<input type="text" id="vlpromis" name="vlpromis" value="<? echo formataMoeda(getByTagName($dados[30]->tags,'vlpromis.1')) ?>" />
	<br />
	
	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão do Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />

	<br style="clear:both" />	
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>	
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
formataTipo8();
</script>