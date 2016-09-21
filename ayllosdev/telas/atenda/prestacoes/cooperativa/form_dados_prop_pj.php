<? 
 /*!
 * FONTE        : form_dados_prop_pj.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 */	
 ?>

<form name="frmDadosPropPj" id="frmDadosPropPj" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Dados para a Proposta') ?></legend>
		
		<label for="vlmedfat"><? echo utf8ToHtml('Faturamento bruto gerencial mensal:') ?></label>
		<input name="vlmedfat" id="vlmedfat" type="text" value="" />
		<a class="lupaFat"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<label id="vlmedfat2" name="vlmedfat2"><? echo utf8ToHtml('(média)') ?></label>
		<br style="clear:both" />
		
		<label for="perfatcl"><? echo utf8ToHtml('Concentração faturamento único cliente %:') ?></label>
		<input name="perfatcl" id="perfatcl" type="text" value="" />
		<br style="clear:both" />
		
		<label for="vlalugue"><? echo utf8ToHtml('Aluguel (Despesas):') ?></label>
		<input name="vlalugue" id="vlalugue" type="text" value="" />
		<br style="clear:both" />
	
	</fieldset>
	  
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_DADOS_PROP_PJ') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_BENS_ASSOC'); return false;" />
	<? } ?>
</div>