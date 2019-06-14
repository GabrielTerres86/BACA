<? 
 /*!
 * FONTE        : form_bcaixa.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 25/10/2011 
 * OBJETIVO     : Formulário de exibição do BCAIXA
 * --------------
 * ALTERAÇÕES   : 27/01/2012 - Incluido tipconsu no frmImprimir (Tiago).
 *
 *                17/04/2013 - Ajuste de botoes voltar e prosseguir para novo padrao 
 *							 - Incluir tpcaicof e cdagenci no frmImprimir (Lucas R.)			
 *							 
 *				  24/09/2013 - Inclusão do input dtmvtolt no form frmImprimir (Carlos)
 * --------------
 */	
?>
<form name="frmBcaixa" id="frmBcaixa" class="formulario" onSubmit="return false;" >	

	<fieldset>
	
		<legend> Autenticadora </legend>	

		
		<label for="nrdmaqui"><? echo utf8ToHtml('Autenticadora:') ?></label>
		<input name="nrdmaqui" id="nrdmaqui" type="text" value="<? echo getByTagName($dados,'nrdmaqui') ?>" />
		
		<label for="qtautent"><? echo utf8ToHtml('Qtd. Autenticações:') ?></label>
		<input name="qtautent" id="qtautent" type="text" value="<? echo getByTagName($dados,'qtautent'); ?>" />
		
		<label for="nrdlacre"><? echo utf8ToHtml('Lacre:') ?></label>
		<input name="nrdlacre" id="nrdlacre" type="text" value="<? echo getByTagName($dados,'nrdlacre') ?>" />

	</fieldset>		

	<fieldset>
	
		<legend> Saldo </legend>	

		<label for="vldsdini"><? echo utf8ToHtml('Saldo Inicial:') ?></label>
		<input name="vldsdini" id="vldsdini" type="text" value="<? echo getByTagName($dados,'vldsdini') ?>" />
		<br />
		
		<label for="vldentra"><? echo utf8ToHtml('Entradas/Recebimentos:') ?></label>
		<input name="vldentra" id="vldentra" type="text" value="<? echo getByTagName($dados,'vldentra') ?>" />
		<br />
		
		<label for="vldsaida"><? echo utf8ToHtml('Saidas/Pagamentos:') ?></label>
		<input name="vldsaida" id="vldsaida" type="text" value="<? echo getByTagName($dados,'vldsaida') ?>" />
		<br />
		
		<label for="vldsdfin"><? echo utf8ToHtml('Saldo Final:') ?></label>
		<input name="vldsdfin" id="vldsdfin" type="text" value="<? echo getByTagName($dados,'vldsdfin') ?>" />

	</fieldset>
			
</form>

<div id="divBotoes" style="margin-bottom:8px">
	
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Prosseguir</a>
		
</div>

<form name="frmImprimir" id="frmImprimir" >
    <input name="dtmvtolt" id="dtmvtolt" type="hidden" value="" />
	<input name="operacao" id="operacao" type="hidden" value="" />
	<input name="cddopcao" id="cddopcao" type="hidden" value="" />
	<input name="ndrrecid" id="ndrrecid" type="hidden" value="" />
	<input name="nrdlacre" id="nrdlacre" type="hidden" value="" />
	<input name="tipconsu" id="tipconsu" type="hidden" value="no" />
	<input name="tpcaicof" id="tpcaicof" type="hidden" value="" />
	<input name="cdagenci" id="cdagenci" type="hidden" value="" />
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>