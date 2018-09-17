<? 
 /*!
 * FONTE        : form_dados_prop_pj.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 *
 * ALTERACOES	: 000: [05/09/2012] Mudar para layout padrao (Gabriel) 
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
	<? if ( $operacao == 'A_DADOS_PROP_PJ' ) { ?>
		<a href="#" class="botao" id="btVoltar"    onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"   onClick="atualizaArray('A_BENS_TITULAR'); return false;">Continuar</a>
	<? } else if ($operacao == 'C_DADOS_PROP_PJ') { ?>
		<a href="#" class="botao" id="btVoltar"    onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"   onClick="controlaOperacao('C_BENS_ASSOC'); return false;">Continuar</a>
	<? } else if ($operacao == 'E_DADOS_PROP_PJ') { ?>
		<a href="#" class="botao" id="btVoltar"    onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_DADOS_PROP_PJ') { ?>
		<a href="#" class="botao" id="btVoltar"    onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"   onClick="atualizaArray('I_BENS_TITULAR'); return false;">Continuar</a>
	<? } ?>
</div>

<script>
	
	highlightObjFocus($('#frmDadosPropPj'));
	
</script>