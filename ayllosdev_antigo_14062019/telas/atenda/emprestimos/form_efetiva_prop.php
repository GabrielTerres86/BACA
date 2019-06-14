<? 
/*!
 * FONTE        : form_efetiva_prop
 * CRIAÇÃO      : Marcelo Leandro Pereira (GATI)
 * DATA CRIAÇÃO : 29/07/2011
 * OBJETIVO     : Formulário de efetivação da proposta
 *
 * ALTERACOES   :  001: [05/09/2012] Mudar para layout padrao (Gabriel)
 * 				   002: [31/10/2018] Alteração do titulo da página - Bruno - Mout's
 */	
 ?>

<form name="frmEfetivaProp" id="frmEfetivaProp" class="formulario condensado">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<?php //PRJ - 438 - Bruno  ?>
		<legend><? echo utf8ToHtml('Efetivação da Proposta') ?></legend>
	
		<label for="cdfinemp"><? echo utf8ToHtml('Final. empréstimo:') ?></label>
		<input name="cdfinemp" id="cdfinemp" type="text" value="" />
		
		<label for="cdlcremp"><? echo utf8ToHtml('Linha de crédito:') ?></label>
		<input name="cdlcremp" id="cdlcremp" type="text" value="" />
		<br />
		
		<label for="nivrisco"><? echo utf8ToHtml('Nível de risco:') ?></label>
		<input name="nivrisco" id="nivrisco" type="text" value="" />
		
		<label for="vlemprst"><? echo utf8ToHtml('Vl. empréstimo:') ?></label>
		<input name="vlemprst" id="vlemprst" type="text" value="" />
		<br />
		
		
		<!--label for="vlfinanc">Vl. Financiado:</label>
		<input name="vlfinanc" id="vlfinanc" type="text" value="" /-->

		<label for="vlpreemp">Valor da parcela:</label>
		<input name="vlpreemp" id="vlpreemp" type="text" value="" />
		<br />
		
		<?php if ($tpemprst == 2) { ?>
		<label for="vlprecar"><? echo utf8ToHtml('Vl. parcela carên.:') ?></label>
		<input name="vlprecar" id="vlprecar" type="text" value="" />
		<br />
		<?php } ?>
		
		<label for="qtpreemp">Qtde parcelas:</label>
		<input name="qtpreemp" id="qtpreemp" type="text" value="" />
		
		<label for="dtdpagto">Data de pagamento:</label>
		<input name="dtdpagto" id="dtdpagto" type="text" value="" />
		<br />
		
		<label for="flgpagto"><? echo utf8ToHtml('Débito em:') ?></label>
		<input name="flgpagto" id="flgpagto" type="text" value="" />			
		
		<label for="nrctaav1">Conta avalista 1:</label>
		<input name="nrctaav1" id="nrctaav1" type="text" value="" />
		<br />
		
		<label for="avalist1">Doc. avalista 1:</label>
		<input name="avalist1" id="avalist1" type="text" value="" />
		
		<label for="nrctaav2">Conta avalista 2:</label>
		<input name="nrctaav2" id="nrctaav2" type="text" value="" />
		<br />
		
		<label for="avalist2">Doc. avalista 2:</label>
		<input name="avalist2" id="avalist2" type="text" value="" />
		
	</fieldset>
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar"  onClick="controlaOperacao('V_EFETIVA'); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" >Continuar</a>
</div>