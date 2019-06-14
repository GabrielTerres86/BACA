<? 
 /*!
 * FONTE        : form_liquidacao.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011 
 * OBJETIVO     : Formulário de exibição da liquidacao
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<form name="frmLiquidacao" id="frmLiquidacao" class="formulario" onSubmit="return false;" >	

	<fieldset>
		<legend> <? echo utf8ToHtml('SILOC (Cobranca NR + DOC NR)') ?> </legend>	
		
		<label for="vlcobbil"><? echo utf8ToHtml('Cobranca/DOC Bilateral:') ?></label>
		<input name="vlcobbil" id="vlcobbil" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vlcobbil')) ?>"/>
		
		<label for="vlcobmlt"><? echo utf8ToHtml('Cobranca/DOC Multilateral:') ?></label>
		<input name="vlcobmlt" id="vlcobmlt" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vlcobmlt')) ?>" />
		
	</fieldset>		


	<fieldset>
		<legend> <? echo utf8ToHtml('COMPE (Cheques NR)') ?> </legend>	

		<label for="vlchqnot"><? echo utf8ToHtml('Compensacao Noturna:') ?></label>
		<input name="vlchqnot" id="vlchqnot" type="text" value="<?php echo getByTagName($registro,'vlchqnot') ?>" />
		
		<label for="vlchqdia"><? echo utf8ToHtml('Compensacao Diurna:') ?></label>
		<input name="vlchqdia" id="vlchqdia" type="text" value="<?php echo formataMoeda(getByTagName($registro,'vlchqdia')) ?>" />
		
	</fieldset>


</form>

<div id="divMsgAjuda">
	<span>Tecle algo ou pressione F4 para sair!</span>

	<div id="divBotoes" >
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onclick="btnVoltar(); return false;" />
	</div>

</div>																			
