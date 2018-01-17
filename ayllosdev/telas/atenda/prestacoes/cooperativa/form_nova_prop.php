<? 
/*!
 * FONTE        : form_nova_prop.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
 * 001: [13/04/2012] Incluir campo dtlibera (Gabriel)
 * 002: [08/04/2014] Alterado fluxo do botao Continuar. (Jorge)
 * 003: [17/06/2014] Trocado posicao dos campos "Linha Credito" por "Finalidade". (Reinert)
 * 004: [11/10/2017] Liberacao melhoria 442 (Heitor - Mouts)
 * 005: [17/01/2018] Inclu�do novo campo (Qualif Oper. Controle) (Diego Simas - AMcom)
 */	
 ?>

<form name="frmNovaProp" id="frmNovaProp" class="formulario condensado">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Nova Proposta de Empréstimo') ?></legend>
	
		<label for="nivrisco"><? echo utf8ToHtml('Nível Risco:') ?></label>
		<select name="nivrisco" id="nivrisco">
			<option value="" > - </option>
			<option value="A">A</option>
			<option value="B">B</option>
			<option value="C">C</option>
			<option value="D">D</option>
			<option value="E">E</option>
			<option value="F">F</option>
			<option value="G">G</option>
			<option value="H">H</option>
		</select>
				
		<label for="nivcalcu">Risco Calc.:</label>
		<input name="nivcalcu" id="nivcalcu" type="text" value="" />
		<br />
		
		<label for="tpemprst">Produto:</label>
		<select name="tpemprst" id="tpemprst">
		</select>
		
		<label for="cdfinemp">Finalidade:</label>
		<input name="cdfinemp" id="cdfinemp" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsfinemp" id="dsfinemp" type="text" value="" />
		<br />		
		
		<label for="vlemprst"><? echo utf8ToHtml('Vl. do Empr.:') ?></label>
		<input name="vlemprst" id="vlemprst" type="text" value="" />
		
		<label for="cdlcremp"><? echo utf8ToHtml('Linha Crédito:') ?></label>
		<input name="cdlcremp" id="cdlcremp" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dslcremp" id="dslcremp" type="text" value="" />
		<br />
		
		<label for="vlpreemp"><? echo utf8ToHtml('Vl. da Prest.:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" value="" />
		
		<label for="idquapro"><? echo utf8ToHtml('Qualif. Oper.:') ?></label>
		<input name="idquapro" id="idquapro" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsquapro" id="dsquapro" type="text" value="" />
		<br />

		<!--- Adi��o de novo campo (Qualif. Oper. Controle) Diego Simas (AMcom) -->
		<label for="idquaprc"><? echo utf8ToHtml('Qualif. Op. Contr:') ?></label>
		<input name="idquaprc" id="idquaprc" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsquaprc" id="dsquaprc" type="text" value="" />
		<br/>		
		
		<label for="qtpreemp">Qtd. de Parc.:</label>
		<input name="qtpreemp" id="qtpreemp" type="text" value="" />		
		
		<label for="percetop">%CET:</label>
		<input name="percetop" id="percetop" type="text" value="" />
		<br />
		
 		<label for="flgpagto">Debitar em:</label>
 		<select name="flgpagto" id="flgpagto">
 			<option value="no" >Conta</option>
 			<option value="yes">Folha</option>
 		</select>
		
		<label for="qtdialib">Liberar em:</label>
		<input name="qtdialib" id="qtdialib" type="text" value="" />
		<label id="duteis"><? echo utf8ToHtml('dias úteis') ?></label>
		<br />
													
		<label for="dtlibera"> <? echo utf8ToHtml("Data Liberação:"); ?> </label>
		<input name="dtlibera" id="dtlibera" type="text" value="">				
		</br>	
													
		<label for="dtdpagto">Data pagto:</label>
		<input name="dtdpagto" id="dtdpagto" type="text" value="" />
		<br />
		
		<label for="flgimppr">Proposta:</label>
		<select name="flgimppr" id="flgimppr">
			<option value=""   > - </option>
			<option value="yes" >Imprime</option>
			<option value="no"><? echo utf8ToHtml('Não Imprime') ?></option>
		</select>
		<br />
						
		<label for="flgimpnp"><? echo utf8ToHtml('Nota Promissória:') ?></label>
		<select name="flgimpnp" id="flgimpnp">
			<option value=""   > - </option>
			<option value="yes" >Imprime</option>
			<option value="no"><? echo utf8ToHtml('Não Imprime') ?></option>
		</select>
		<br />
		
		<label for="dsratpro"> <? echo utf8ToHtml("Rat. Pro:"); ?> </label>
		<input name="dsratpro" id="dsratpro" type="text" value="">				

		<label for="dsratatu"><? echo utf8ToHtml("Rat. Atu:"); ?></label>
		<input name="dsratatu" id="dsratatu" type="text" value="" />
		<br />
		
		<label for="dsctrliq"><? echo utf8ToHtml('Liquidações:') ?></label>
		<input name="dsctrliq" id="dsctrliq" type="text" value="" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<br />
		
	</fieldset>
</form>

<div id="divBotoes">
	<? if (($operacao == 'C_NOVA_PROP') || ($operacao == 'C_NOVA_PROP_V') ) { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('TC'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_DADOS_AVAL'); return false;" />
	<? } ?>
</div>