<? 
/*!
 * FONTE        : form_visualiza.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 17/02/2010 
 * OBJETIVO     : Formulário de visualização da impressão da tela ANOTA
 */	
 ?>

<form name="frmVisualiza" id="frmVisualiza" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
	
		<label for="nrdconta">Conta:</label>
		<input name="nrdconta" id="nrdconta" type="text" value="<? echo getByTagName($associado,'nrdconta') ?>" />
			
		<label for="nmprimtl"><? echo utf8ToHtml('Titular:') ?></label>
		<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo getByTagName($associado,'nmprimtl') ?>" />
		<br />
					
		<label for="dtmvtolt">Em:</label>
		<input name="dtmvtolt" id="dtmvtolt" type="text" value="<? echo getByTagName($registros[0]->tags,'dtmvtolt') ?>" />
			
		<label for="hrtransc"><? echo utf8ToHtml('às:') ?></label>
		<input name="hrtransc" id="hrtransc" type="text" value="<? echo getByTagName($registros[0]->tags,'hrtransc') ?>" />
			
		<label for="nmoperad">Por:</label>
		<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($registros[0]->tags,'cdoperad') ?>" />
		<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($registros[0]->tags,'nmoperad') ?>" />
		<br />
		
		<?if ( getByTagName($registros[0]->tags,'flgprior') == 'yes') {?>
			<label id="flgprior"><? echo utf8ToHtml('** MENSAGEM PRIORITÁRIA **') ?></label>
			<br />
		<?}?>
		
		<textarea name="dsobserv" id="dsobserv"><? echo getByTagName($registros[0]->tags,'dsobserv') ?></textarea>
	
	</fieldset>
		
</form>

<div id="divBotoes">
	<? if ( $operacao == 'TC' ) { ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('FC'); return false;" />
		<input type="image" id="btImprimir"  src="<?php echo $UrlImagens; ?>botoes/imprimir.gif"  onClick="Gera_Impressao(); return false;" />
	<? } else{ ?>
		<input type="image" id="btVoltar"    src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
	<? } ?>
</div>