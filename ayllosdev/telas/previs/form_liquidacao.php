<? 
 /*!
 * FONTE        : form_liquidacao.php								Última alteração:
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011 
 * OBJETIVO     : Formulário de exibição da liquidacao
 * --------------
 * ALTERAÇÕES   : 21/03/2016 - Ajuste layout, valores negativos (Adriano)
 * --------------
 */	
?>
<form name="frmLiquidacao" id="frmLiquidacao" class="formulario" onSubmit="return false;" >	

	<fieldset>
		<legend> <? echo utf8ToHtml('SILOC (Cobranca NR + DOC NR)') ?> </legend>	
		
		<label for="vlcobbil"><? echo utf8ToHtml('Cobranca/DOC Bilateral:') ?></label>
		<input name="vlcobbil" id="vlcobbil" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($registro,'vlcobbil')),2,",","."); ?>"/>
		
		<label for="vlcobmlt"><? echo utf8ToHtml('Cobranca/DOC Multilateral:') ?></label>
		<input name="vlcobmlt" id="vlcobmlt" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($registro,'vlcobmlt')),2,",","."); ?>" />
		
	</fieldset>		


	<fieldset>
		<legend> <? echo utf8ToHtml('COMPE (Cheques NR)') ?> </legend>	

		<label for="vlchqnot"><? echo utf8ToHtml('Compensacao Noturna:') ?></label>
		<input name="vlchqnot" id="vlchqnot" type="text" value="<?php echo number_format(str_replace(",",".",getByTagName($registro,'vlchqnot')),2,",","."); ?>" />
		
		<label for="vlchqdia"><? echo utf8ToHtml('Compensacao Diurna:') ?></label>
		<input name="vlchqdia" id="vlchqdia" type="text" value=" <?php echo formataMoeda(getByTagName($registro,'vlchqdia')) ?>" />
		
	</fieldset>


</form>

<div id="divBotoesLiquidacoes" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">	
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>

