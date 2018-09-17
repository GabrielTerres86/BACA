<? 
/*!
 * FONTE        : form_org_prot_cred.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 *
 * ALTERACOES   : 13/06/2012 - Tratar da liquidacao na 1a tela (Gabriel).
 *                04/09/2012 - Validar todos os campos antes de sair(Gabriel). 
 *				  24/12/2013 - Alterado botao de continuar, quando for operacao "C_PROT_CRED", de "" para "C_COMITE_APROV". (Jorge)
 * 				  04/02/2014 - Adicionado campo flgcentr. (Jorge)
 *                08/09/2014 - Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 *                28/11/2014 - Retirar consula do 2.do titular (Jonata-RKAM)
 */	
 
 
 ?>

<form name="frmOrgProtCred" id="frmOrgProtCred" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	<input id="flgcentr" name="flgcentr" type="hidden" value="" />
	<input id="dtcnsspc" name="dtcnsspc" type="hidden" value="" />
	<input id="nrinfcad" name="nrinfcad" type="hidden" value="" />
	<input id="dsinfcad" name="dsinfcad" type="hidden" value="" />
		
	<fieldset>
		<legend><? echo utf8ToHtml('Central de Risco - Bacen') ?></legend>
	
		<label for="dtdrisco"><? echo utf8ToHtml('Consulta 1º Tit.:') ?></label>
		<input name="dtdrisco" id="dtdrisco" type="text" value="" />
		
		<label for="qtifoper">Qtd. IF com ope.:</label>
		<input name="qtifoper" id="qtifoper" type="text" value="" />
		
		<label for="qtopescr"><? echo utf8ToHtml('Qtd. Operações:') ?></label>
		<input name="qtopescr" id="qtopescr" type="text" value="" />
		<br />
						
		<label for="vltotsfn">Endividamento:</label>
		<input name="vltotsfn" id="vltotsfn" type="text" value="" />
						
		<label for="vlopescr">Vencidas:</label>
		<input name="vlopescr" id="vlopescr" type="text" value="" />
						
		<label for="vlrpreju">Prej.:</label>
		<input name="vlrpreju" id="vlrpreju" type="text" value="" />
		<br />
		
		<label for="dtoutris"><? echo utf8ToHtml('Consulta Cônjuge:') ?></label>
		<input name="dtoutris" id="dtoutris" type="text" value="" />
		
		<label for="vlsfnout"><? echo utf8ToHtml('Endiv. Cônjuge:') ?></label>
		<input name="vlsfnout" id="vlsfnout" type="text" value="" />
		<br />
							
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Garantias') ?></legend>
	
		<label for="nrgarope">Garantia:</label>
		<input name="nrgarope" id="nrgarope" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsgarope" id="dsgarope" type="text" value="" />
						
		<label for="nrliquid">Liquidez:</label>
		<input name="nrliquid" id="nrliquid" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsliquid" id="dsliquid" type="text" value="" />
		<br />
		
		<label for="nrpatlvr">Patr. pessoal livre:</label>
		<input name="nrpatlvr" id="nrpatlvr" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dspatlvr" id="dspatlvr" type="text" value="" />
		<br />
	
		<label for="nrperger"><? echo utf8ToHtml('Percepção geral com relação a empresa:') ?></label>
		<input name="nrperger" id="nrperger" type="text" value="" />
		<a id='lupanrperger'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsperger" id="dsperger" type="text" value="" />
		<br />
		
							
	</fieldset>
				
</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_PROT_CRED' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_DADOS_PROP'); return false;">Voltar</a> 
		<a href="#" class="botao" id="btSalvar" onClick="validaItensRating('<? echo $operacao; ?>' , false); return false;">Continuar</a>
	<? } else if ($operacao == 'C_PROT_CRED') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_PROTECAO_TIT'); return false;">Continuar</a>		
	<? } else if ($operacao == 'E_PROT_CRED') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_PROT_CRED') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_DADOS_PROP'); return false;">Voltar</a> 
		<a href="#" class="botao" id="btSalvar" onClick="validaItensRating('<? echo $operacao; ?>', false);return false;">Continuar</a>
	<? } ?>
</div>

<script>
	
	$(document).ready(function() {
	
		 highlightObjFocus($('#frmOrgProtCred'));
	});
	
</script>