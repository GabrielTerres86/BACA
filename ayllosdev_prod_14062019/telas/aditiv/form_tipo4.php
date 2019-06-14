<? 
 /*!
 * FONTE        : form_tipo4.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 28/09/2011 
 * OBJETIVO     : Formulário de exibição do TIPO 4 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 *
 *              : 08/11/2014 - Gerar a impressao pelo Gera_Impressao 
							   (Jonata-RKAM).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('4 - Alteração de Avalista/Fiador') ?></legend>

	<label for="dscpfavl"><? echo utf8ToHtml('Número do CPF:') ?></label>
	<input type="text" id="dscpfavl" name="dscpfavl" value="<? echo formatar(getByTagName($dados,'nrcpfcgc'),'cpf')?>" />
	<br />

	<label for="nmdavali"><? echo utf8ToHtml('Nome do Avalista:') ?></label>	
	<input type="text" id="nmdavali" name="nmdavali" value="<? echo getByTagName($dados,'nmdavali')?>" />
	<br />

	<label for="dtmvtolt"><? echo utf8ToHtml('Data de Inclusão do Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />
	
	<br style="clear:both" />	
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Cancelar</a>
	<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
</div>

<script>
formataTipo4();
</script>