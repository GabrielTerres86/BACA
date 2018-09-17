<? 
 /*!
 * FONTE        : form_anota.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/02/2010 
 * OBJETIVO     : Formulário de exibição das Anotações
 */	
?>

<form name="frmAnota" id="frmAnota" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
			
	<fieldset>
		<legend><? echo utf8ToHtml('Texto') ?></legend>
		
		<label for="flgprior"><? echo utf8ToHtml('Prioritário ? :') ?></label>
		<input id='flgpryes' name="flgprior" type="radio" class="radio" value="yes" <? if (getByTagName($registros[0]->tags,'flgprior') == 'yes') { echo ' checked'; } ?> />
		<label for="flgyes" class="radio">Sim</label>
		<input name="flgprior" type="radio" class="radio" value="no" <? if (getByTagName($registros[0]->tags,'flgprior') == 'no') { echo ' checked'; } ?> />
		<label for="flgno" class="radio"><? echo utf8ToHtml('Não') ?></label>
		<br />
		
		<textarea name="dsobserv" id="dsobserv"><? echo getByTagName($registros[0]->tags,'dsobserv') ?></textarea>
							
	</fieldset>
			
			
</form>

<div id="divBotoes">	
	<? if ( $operacao == 'TI' ) { ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('IF'); return false;" />
		<input type="image" id="btSalvar"    src="<?php echo $UrlImagens; ?>botoes/concluir.gif"  onClick="controlaOperacao('IV'); return false;" />
	<? } else if ($operacao == 'TC') { ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('FC'); return false;" />
	<? } else if ($operacao == 'TA') { ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"      onClick="controlaOperacao('AT'); return false;" />
		<input type="image" id="btSalvar"    src="<?php echo $UrlImagens; ?>botoes/concluir.gif"    onClick="controlaOperacao('AV'); return false;" />
	<? } ?>
</div>