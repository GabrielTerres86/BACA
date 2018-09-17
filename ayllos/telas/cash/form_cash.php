<? 
 /*!
 * FONTE        : form_bcaixa.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011 
 * OBJETIVO     : Formulário de exibição do BCAIXA
 * --------------
 * ALTERAÇÕES   : 17/09/2012 - Implementação do novo layout (David Kruger).
 *
 *				  18/11/2013 - Adicioando campo flgblsaq (Jorge).
 *
 *                25/07/2017 - #712156 Melhoria 274, inclusão do campo flgntcem (Carlos)
 *                
 * --------------
 */	
?>
<form name="frmCash" id="frmCash" class="formulario" onSubmit="return false;" >	

	<input name="nrtempor" id="nrtempor" type="hidden" value="<? echo getByTagName($terminal,'nrtempor') ?>" />
	<input name="tpdispen" id="tpdispen" type="hidden" value="<? echo getByTagName($terminal,'tpdispen') ?>" />
	<input name="cdagenci" id="cdagenci" type="hidden" value="<? echo getByTagName($terminal,'cdagenci') ?>" />
	<input name="cdsitfin" id="cdsitfin" type="hidden" value="<? echo getByTagName($terminal,'cdsitfin') ?>" />
	<input name="dsfabtfn" id="dsfabtfn" type="hidden" value="<? echo getByTagName($terminal,'dsfabtfn') ?>" />
	<input name="dsmodelo" id="dsmodelo" type="hidden" value="<? echo getByTagName($terminal,'dsmodelo') ?>" />
	<input name="dsdserie" id="dsdserie" type="hidden" value="<? echo getByTagName($terminal,'dsdserie') ?>" />
	<input name="nmnarede" id="nmnarede" type="hidden" value="<? echo getByTagName($terminal,'nmnarede') ?>" />
	<input name="nrdendip" id="nrdendip" type="hidden" value="<? echo getByTagName($terminal,'nrdendip') ?>" />
	<input name="qtcasset" id="qtcasset" type="hidden" value="<? echo getByTagName($terminal,'qtcasset') ?>" />
	<input name="dsininot" id="dsininot" type="hidden" value="<? echo getByTagName($terminal,'dsininot') ?>" />
	<input name="dsfimnot" id="dsfimnot" type="hidden" value="<? echo getByTagName($terminal,'dsfimnot') ?>" />
	<input name="dssaqnot" id="dssaqnot" type="hidden" value="<? echo getByTagName($terminal,'dssaqnot') ?>" />
	<input name="dstempor" id="dstempor" type="hidden" value="<? echo getByTagName($terminal,'dstempor') ?>" />
	<input name="dsdispen" id="dsdispen" type="hidden" value="<? echo getByTagName($terminal,'dsdispen') ?>" />
	<input name="dssittfn" id="dssittfn" type="hidden" value="<? echo getByTagName($terminal,'dssittfn') ?>" />
	<input name="flsistaa" id="flsistaa" type="hidden" value="<? echo getByTagName($terminal,'flsistaa') ?>" />
	<input name="dsterfin" id="dsterfin" type="hidden" value="<? echo getByTagName($terminal,'dsterfin') ?>" />
	<input name="flgblsaq" id="flgblsaq" type="hidden" value="<? echo getByTagName($terminal,'flgblsaq') ?>" />
	<input name="flgntcem" id="flgntcem" type="hidden" value="<? echo getByTagName($terminal,'flgntcem') ?>" />

	<fieldset>
	
		<legend> <? echo utf8ToHtml('Terminal') ?> </legend>	

		<label for="lacre123"><? echo utf8ToHtml('Lacre:') ?></label>
		<label for="qtdnotas"><? echo utf8ToHtml('Qtd. Notas:') ?></label>
		<label for="vldnotas"><? echo utf8ToHtml('Valor da Nota:') ?></label>
		<label for="vldtotal"><? echo utf8ToHtml('Valor Total:') ?></label>

		<br />
		
		<label for="casseteA"><? echo utf8ToHtml('Cassete A:') ?></label>
		<label for="nrlacreA"></label>
		<input name="nrlacreA" id="nrlacreA" type="text" value="<? echo getByTagName($nrdlacre,'nrdlacre.1') ?>" />
		<label for="qtdnotaA"></label>
		<input name="qtdnotaA" id="qtdnotaA" type="text" value="<? echo getByTagName($qtnotcas,'qtnotcas.1') ?>" />
		<label for="vldnotaA"></label>
		<input name="vldnotaA" id="vldnotaA" type="text" value="<? echo getByTagName($vlnotcas,'vlnotcas.1') ?>" />
		<label for="vltotalA"></label>
		<input name="vltotalA" id="vltotalA" type="text" value="<? echo getByTagName($vltotcas,'vltotcas.1') ?>" />
		
		<br />
		
		<label for="casseteB"><? echo utf8ToHtml('Cassete B:') ?></label>
		<label for="nrlacreB"></label>
		<input name="nrlacreB" id="nrlacreB" type="text" value="<? echo getByTagName($nrdlacre,'nrdlacre.2'); ?>" />
		<label for="qtdnotaB"></label>
		<input name="qtdnotaB" id="qtdnotaB" type="text" value="<? echo getByTagName($qtnotcas,'qtnotcas.2'); ?>" />
		<label for="vldnotaB"></label>
		<input name="vldnotaB" id="vldnotaB" type="text" value="<? echo getByTagName($vlnotcas,'vlnotcas.2'); ?>" />
		<label for="vltotalB"></label>
		<input name="vltotalB" id="vltotalB" type="text" value="<? echo getByTagName($vltotcas,'vltotcas.2'); ?>" />
		
		<br />
		
		<label for="casseteC"><? echo utf8ToHtml('Cassete C:') ?></label>
		<label for="nrlacreC"></label>
		<input name="nrlacreC" id="nrlacreC" type="text" value="<? echo getByTagName($nrdlacre,'nrdlacre.3') ?>" />
		<label for="qtdnotaC"></label>
		<input name="qtdnotaC" id="qtdnotaC" type="text" value="<? echo getByTagName($qtnotcas,'qtnotcas.3') ?>" />
		<label for="vldnotaC"></label>
		<input name="vldnotaC" id="vldnotaC" type="text" value="<? echo getByTagName($vlnotcas,'vlnotcas.3') ?>" />
		<label for="vltotalC"></label>
		<input name="vltotalC" id="vltotalC" type="text" value="<? echo getByTagName($vltotcas,'vltotcas.3') ?>" />
		
		<br />
		
		<label for="casseteD"><? echo utf8ToHtml('Cassete D:') ?></label>
		<label for="nrlacreD"></label>
		<input name="nrlacreD" id="nrlacreD" type="text" value="<? echo getByTagName($nrdlacre,'nrdlacre.4') ?>" />
		<label for="qtdnotaD"></label>
		<input name="qtdnotaD" id="qtdnotaD" type="text" value="<? echo getByTagName($qtnotcas,'qtnotcas.4') ?>" />
		<label for="vldnotaD"></label>
		<input name="vldnotaD" id="vldnotaD" type="text" value="<? echo getByTagName($vlnotcas,'vlnotcas.4') ?>" />
		<label for="vltotalD"></label>
		<input name="vltotalD" id="vltotalD" type="text" value="<? echo getByTagName($vltotcas,'vltotcas.4') ?>" />
		
		<br />
		
		<label for="rejeitaR"><? echo utf8ToHtml('Rejeitados:') ?></label>
		<label for="nrlacreR"></label>
		<input name="nrlacreR" id="nrlacreR" type="text" value="<? echo getByTagName($nrdlacre,'nrdlacre.5') ?>" />
		<label for="qtdnotaR"></label>
		<input name="qtdnotaR" id="qtdnotaR" type="text" value="<? echo getByTagName($qtnotcas,'qtnotcas.5') ?>" />
		<label for="vltotalR"></label>
		<input name="vltotalR" id="vltotalR" type="text" value="<? echo getByTagName($vltotcas,'vltotcas.5') ?>" />

		<br />
		
		<label for="total12G"><? echo utf8ToHtml('Total:') ?></label>
		<label for="qtdnotaG"></label>
		<input name="qtdnotaG" id="qtdnotaG" type="text" value="<? echo getByTagName($terminal,'qtdnotaG') ?>" />
		<label for="vltotalG"></label>
		<input name="vltotalG" id="vltotalG" type="text" value="<? echo getByTagName($terminal,'vltotalG') ?>" />

		<br style="clear:both" /><br /><br />
		
		<label for="qttotalP">Envelopes:</label>
		<input name="qttotalP" id="qttotalP" type="text" value="<? echo getByTagName($terminal,'qtenvelo') ?>" />
		<label for="dssittfn"><? echo utf8ToHtml('Situação:') ?></label>
		<input name="dssittfn" id="dssittfn" type="text" value="<? echo getByTagName($terminal,'dssittfn') ?>" />
		
		<br />
		
		<label for="nmoperad">Operador:</label>
		<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($terminal,'nmoperad') ?>" />
		
	</fieldset>		

</form>

<div id="divBotoes" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="mostraTransacao(); return false;">Transa&ccedil;&atilde;o</a>
	<a href="#" class="botao" onclick="mostraData('operacao'); return false;">Opera&ccedil;&atilde;o</a>
	<a href="#" class="botao" onclick="mostraOpcao('sensores');return false;">Sensores</a>
	<a href="#" class="botao" onclick="mostraOpcao('configuracao');return false;">Configura&ccedil;&atilde;o</a>
	<a href="#" class="botao" onclick="mostraData('saldos');return false;">Saldos Anteriores</a>
	<a href="#" class="botao" onclick="mostraData('log');return false;">Log</a>
</div>

<script> 
	
	$(document).ready(function(){
		highlightObjFocus($('#frmCash'));
	});

</script>