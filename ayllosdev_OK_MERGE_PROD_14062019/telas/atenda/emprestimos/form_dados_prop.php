<? 
 /*!
 * FONTE        : form_dados_prop.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 * 001: [29/11/2011] Ajuste para a inclusao do campo Justificativa (Adriano)
 * 002: [05/09/2012] Mudar para layout padrao (Gabriel)
 * 003: [26/03/2013] Ajustar parametro enviado na consulta (Gabriel) 
 * 004: [08/09/2014] Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 */
 ?>

<form name="frmDadosProp" id="frmDadosProp" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	<input id="nrctacje" name="nrctacje" type="hidden" value="" />
	<input id="nrcpfcjg" name="nrcpfcjg" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Rendimentos') ?></legend>
	
		<label for="vlsalari"><? echo utf8ToHtml('Salário:') ?></label>
		<input name="vlsalari" id="vlsalari" type="text" value="" />
		
		<label for="vloutras">Demais Tit./Outros:</label>
		<input name="vloutras" id="vloutras" type="text" value="" />
		<br style="clear:both" />
		
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Outros Rendimentos') ?></legend> 
	
		<label for="tpdrend1">Origem:</label>
		<input name="tpdrend1" id="tpdrend1" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend1" id="dsdrend1" type="text" value="" />
		
		<label for="vldrend1">Valor:</label>
		<input name="vldrend1" id="vldrend1" type="text" value="" />
		<br />
		
		<label for="tpdrend2">Origem:</label>
		<input name="tpdrend2" id="tpdrend2" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend2" id="dsdrend2" type="text" value="" />
		
		<label for="vldrend2">Valor:</label>
		<input name="vldrend2" id="vldrend2" type="text" value="" />
		<br />
		
		<label for="tpdrend3">Origem:</label>
		<input name="tpdrend3" id="tpdrend3" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend3" id="dsdrend3" type="text" value="" />
		
		<label for="vldrend3">Valor:</label>
		<input name="vldrend3" id="vldrend3" type="text" value="" />
		<br />
		
		<label for="tpdrend4">Origem:</label>
		<input name="tpdrend4" id="tpdrend4" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend4" id="dsdrend4" type="text" value="" />
		
		<label for="vldrend4">Valor:</label>
		<input name="vldrend4" id="vldrend4" type="text" value="" />
		<br />
		
		<label for="tpdrend5">Origem:</label>
		<input name="tpdrend5" id="tpdrend5" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend5" id="dsdrend5" type="text" value="" />
		
		<label for="vldrend5">Valor:</label>
		<input name="vldrend5" id="vldrend5" type="text" value="" />
		<br />
		
		<label for="tpdrend6">Origem:</label>
		<input name="tpdrend6" id="tpdrend6" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsdrend6" id="dsdrend6" type="text" value="" />
		
		<label for="vldrend6">Valor:</label>
		<input name="vldrend6" id="vldrend6" type="text" value="" />
		<br />
		
		
		<label for="dsjusren">Justificativa:</label>
		<textarea name="dsjusren" id="dsjusren"></textarea>
		
		<br style="clear:both" />	
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Informações do Cônjuge') ?></legend> 
					
		<label for="vlsalcon"><? echo utf8ToHtml('Conjugê - Salário:') ?></label>
		<input name="vlsalcon" id="vlsalcon" type="text" value="" />
		
		<label for="nmextemp">Local de Trabalho:</label>
		<input name="nmextemp" id="nmextemp" type="text" value="" />
		<br />
		
		<label for="flgdocje"><? echo utf8ToHtml('Co-Responsável:') ?></label>
		<input name="flgdocje" id="flgYes" type="radio" class="radio" value="yes" />
		<label for="flgYes" class="radio" >Sim</label>
		<input name="flgdocje" id="flgNo" type="radio" class="radio" value="no" />
		<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>
										
		<label for="vlalugue">Aluguel (Despesas):</label>
		<input name="vlalugue" id="vlalugue" type="text" value="" />
		<br />
		
		<label for="inconcje"><?php echo utf8ToHtml('Consultar Cônjuge:') ?></label>
		<input name="inconcje" id="inconcje_1" type="radio" class="radio" value="yes" />
		<label for="flgYes" class="radio" >Sim</label>
		<input name="inconcje" id="inconcje_2" type="radio" class="radio" value="no" />
		<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>
	
	</fieldset>
	  
</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_DADOS_PROP' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"    onClick="validaJustificativa('A_BENS_TITULAR'); return false;">Continuar</a>	
	<? } else if ($operacao == 'C_DADOS_PROP') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar"    onClick="validaJustificativa('C_BENS_ASSOC'); return false;">Continuar</a>	
	<? } else if ($operacao == 'E_DADOS_PROP') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>	
	<? } else if ($operacao == 'I_DADOS_PROP') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaJustificativa('I_BENS_TITULAR'); return false;">Continuar</a>
	<? } ?>
</div>

<script>
	
	$(document).ready(function() {
	
		 highlightObjFocus($('#frmDadosProp'));
	});
	
</script>