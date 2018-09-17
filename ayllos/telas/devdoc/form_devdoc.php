<? 
 /*!
 * FONTE        : form_devdoc.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/03/2014 
 * OBJETIVO     : Formulário de informacoes do documento
 * --------------
 * ALTERAÇÕES   : 22/09/2014 - Inclusão da coluna Ag Fav (Marcos-Supero)
 * --------------
 */	
?>



<form action="" method="post" id="frmDetalheDoc" name="frmDetalheDoc">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<label for="cdmotdev"><? echo utf8ToHtml('Motivo:') ?></label>
	<input name="cdmotdev" id="cdmotdev" type="text" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
	<input name="nrdocmto" id="nrdocmto" type="text" />
	<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>
	<input name="dtmvtolt" id="dtmvtolt" type="text" />
	<label for="vldocmto"><? echo utf8ToHtml('Valor:') ?></label>
	<input name="vldocmto" id="vldocmto" type="text" />
	
	<fieldset>
		<legend>Favorecido</legend>
		<label for="cdagenci"><? echo utf8ToHtml('Ag Fav:') ?></label>
		<input name="cdagenci" id="cdagenci" type="text" />
		<label for="nrdconta"><? echo utf8ToHtml('Conta/Dv:') ?></label>
		<input name="nrdconta" id="nrdconta" type="text" />
		<label for="nmfavore"><? echo utf8ToHtml('Favorecido:') ?></label>
		<input name="nmfavore" id="nmfavore" type="text" />
		<label for="nrcpffav"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input name="nrcpffav" id="nrcpffav" type="text" />
	</fieldset>
	
	<fieldset>
		<legend>Emitente</legend>
		<label for="nrctadoc"><? echo utf8ToHtml('Conta/Dv:') ?></label>
		<input name="nrctadoc" id="nrctadoc" type="text" />
		<label for="nmemiten"><? echo utf8ToHtml('Emitente:') ?></label>
		<input name="nmemiten" id="nmemiten" type="text" />
		<label for="nrcpfemi"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input name="nrcpfemi" id="nrcpfemi" type="text" />
		<label for="cdbandoc"><? echo utf8ToHtml('Banco:') ?></label>
		<input name="cdbandoc" id="cdbandoc" type="text" />
		<label for="cdagedoc"><? echo utf8ToHtml('Ag&ecirc;ncia:') ?></label>
		<input name="cdagedoc" id="cdagedoc" type="text" />
		<label for="blank"></label>
	</fieldset>
	
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="fechaDetalhe(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="btnSalvar(); return false;">Salvar</a>				
	<br />
</div>