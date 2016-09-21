<? 
 /*!
 * FONTE        : form_mantal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 21/06/2011 
 * OBJETIVO     : Formulário de exibição do MANTAL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<form name="frmMantal" id="frmMantal" class="formulario">	

	<input name="nrdconta" id="nrdconta" type="hidden" value="" />
	<input name="cheques" id="cheques" type="hidden" value="" />
	<input name="criticas" id="criticas" type="hidden" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<fieldset>
	
		<label for="cdbanchq"><? echo utf8ToHtml('Banco:') ?></label>
		<input name="cdbanchq" id="cdbanchq" type="text" value="<? echo getByTagName($registros[0]->tags,'cdbanchq') == '0' ? '' : getByTagName($registros[0]->tags,'cdbanchq') ?>" />
		
		<label for="cdagechq"><? echo utf8ToHtml('Agência:') ?></label>
		<input name="cdagechq" id="cdagechq" type="text" value="<? echo getByTagName($registros[0]->tags,'cdagechq') == '0' ? '' : getByTagName($registros[0]->tags,'cdagechq') ?>" />
		
		<label for="nrctachq"><? echo utf8ToHtml('Conta cheque:') ?></label>
		<input name="nrctachq" id="nrctachq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrctachq') == '0' ? '' : getByTagName($registros[0]->tags,'nrctachq') ?>" />

		<label for="nrinichq"><? echo utf8ToHtml('Inicial:') ?></label>
		<input name="nrinichq" id="nrinichq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrinichq') == '0' ? '' : getByTagName($registros[0]->tags,'nrinichq') ?>" />

		<label for="nrfimchq"><? echo utf8ToHtml('Final:') ?></label>
		<input name="nrfimchq" id="nrfimchq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrfimchq') == '0' ? '' : getByTagName($registros[0]->tags,'nrfimchq') ?>" />
		<input type="image" src="<?php echo $UrlImagens; ?>/botoes/ok.gif">
	</fieldset>		
			
</form>

<div id="divTabMantal"></div>

<div id="divBotoes">	
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onclick="btnVoltar(); return false;"   />
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onclick="btnConcluir(); return false;" />

</div>