<? 
 /*!
 * FONTE        : form_dctror.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/06/2011 
 * OBJETIVO     : Formulário de exibição das Contra-Ordens/Avisos
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
//bruno - prj 438 - bug 100	
?>
<link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
<link href="../../css/estilo.css" rel="stylesheet" type="text/css">
<form name="frmDctror" id="frmDctror" class="formulario">	

	<input name="nrdconta" id="nrdconta" type="hidden" value="" />
	<input name="cddopcao" id="cddopcao" type="hidden" value="" />
	<input name="contra" id="contra" type="hidden" value="" />

	<fieldset>

		<label for="cdsitdtl"><? echo utf8ToHtml('Situação titular:') ?></label>
		<input name="cdsitdtl" id="cdsitdtl" type="text" value="<? echo getByTagName($registros[0]->tags,'cdsitdtl') ?>" />
		<input name="dssitdtl" id="dssitdtl" type="text" value="<? echo getByTagName($registros[0]->tags,'dssitdtl') ?>" />
	
		<label for="dtemscor"><? echo utf8ToHtml('Data de emissão:') ?></label>
		<input name="dtemscor" id="dtemscor" type="text" value="<? echo getByTagName($registros[0]->tags,'dtemscor') ?>" />
		<br />
		<label for="dtvalcor"><? echo utf8ToHtml('Data de Validade:') ?></label>
		<input name="dtvalcor" id="dtvalcor" type="text" value="<? echo getByTagName($registros[0]->tags,'dtvalcor') ?>" />	
	</fieldset>
			
	<fieldset>
	
		<label for="cdhistor"><? echo utf8ToHtml('Histórico:') ?></label>
		<input name="cdhistor" id="cdhistor" type="text" value="<? echo getByTagName($registros[0]->tags,'cdhistor') == '0' ? '' : getByTagName($registros[0]->tags,'cdhistor') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<label for="cdbanchq"><? echo utf8ToHtml('Banco:') ?></label>
		<input name="cdbanchq" id="cdbanchq" type="text" value="<? echo getByTagName($registros[0]->tags,'cdbanchq') == '0' ? '' : getByTagName($registros[0]->tags,'cdbanchq') ?>" />
		
		<label for="cdagechq"><? echo utf8ToHtml('Agência:') ?></label>
		<input name="cdagechq" id="cdagechq" type="text" value="<? echo getByTagName($registros[0]->tags,'cdagechq') == '0' ? '' : getByTagName($registros[0]->tags,'cdagechq') ?>" />
		<br />
		
		<label for="nrctachq"><? echo utf8ToHtml('Conta cheque:') ?></label>
		<input name="nrctachq" id="nrctachq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrctachq') == '0' ? '' : getByTagName($registros[0]->tags,'nrctachq') ?>" />

		<label for="nrinichq"><? echo utf8ToHtml('Inicial:') ?></label>
		<input name="nrinichq" id="nrinichq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrinichq') == '0' ? '' : getByTagName($registros[0]->tags,'nrinichq') ?>" />

		<label for="nrfinchq"><? echo utf8ToHtml('Final:') ?></label>
		<input name="nrfinchq" id="nrfinchq" type="text" value="<? echo getByTagName($registros[0]->tags,'nrfinchq') == '0' ? '' : getByTagName($registros[0]->tags,'nrfinchq') ?>" />

		<br />
		
	</fieldset>		
			
</form>

<div id="divTabDctror"></div>

<div id="divBotoes">	
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onclick="btnVoltar(); return false;"   />
</div>