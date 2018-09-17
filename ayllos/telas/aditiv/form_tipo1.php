<? 
 /*!
 * FONTE        : form_tipo1.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Formulário de exibição do TIPO 8 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario" >

	<input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($dados,'nmprimtl')?>" />

	<fieldset>
	<legend><? echo utf8ToHtml('1 - Alteração da Data do Debito') ?></legend>
	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt') ?>" />
	<br />
	
	<label for="flgpagto"><? echo utf8ToHtml('Debitar em:') ?></label>	
	<select id="flgpagto" name="flgpagto">
	<option value="yes" <? echo getByTagName($dados,'flgpagto') == 'yes' ? 'selected' : '' ?> >(F)olha de Pagto</option>
	<option value="no" <? echo getByTagName($dados,'flgpagto')  == 'no'  ? 'selected' : '' ?> >(C)onta Corrente</option>
	</select>
	<br />

	<label for="dtdpagto">Data Pagamento:</label>
	<input type="text" id="dtdpagto" name="dtdpagto" value="<? echo getByTagName($dados,'dtdpagto')?>" />

	<br style="clear:both" />	
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
formataTipo1('<? echo getByTagName($dados,'tpdescto') ?>');
</script>