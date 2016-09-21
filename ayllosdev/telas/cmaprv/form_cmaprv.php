<? 
 /*!
 * FONTE        : form_cmaprv.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 29/09/2011 
 * OBJETIVO     : Formulário de exibição do CMAPRV
 * --------------
 * ALTERAÇÕES   :
 * 001: 18/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * 002: 16/03/2015 - Jonata (RKAM)   : Novo campo Parecer de Credito.
 * --------------
 */	
?>
<form name="frmCmaprv" id="frmCmaprv" class="formulario" onSubmit="return false;" >	

	<input type="hidden" name="instatus" id="instatus">

	<fieldset>
	
		<legend><? echo utf8ToHtml('Situação') ?></legend>	

		<input name="nrdcont1" id="nrdcont1" type="hidden" value="" />
		<input name="nrctremp" id="nrctremp" type="hidden" value="" />
		<input name="insitaux" id="insitaux" type="hidden" value="" />
		<input name="nrctrliq" id="nrctrliq" type="hidden" value="" />
		<input name="vlemprst" id="vlemprst" type="hidden" value="" />
		<input name="dsobscmt" id="dsobscmt" type="hidden" value="" />
		
		
		<label for="qtpreemp"><? echo utf8ToHtml('Qtde Prestações:') ?></label>
		<input name="qtpreemp" id="qtpreemp" type="text" />
			
		<label for="vlpreemp"><? echo utf8ToHtml('Vlr. Prestação:') ?></label>
		<input name="vlpreemp" id="vlpreemp" type="text" />
		<br />	
		
		<label for="dtmvtolt"><? echo utf8ToHtml('Data Proposta:') ?></label>
		<input name="dtmvtolt" id="dtmvtolt" type="text" />
		
		<label for="dsstatus"><? echo utf8ToHtml('Parecer de Crédito:') ?></label>
		<input name="dsstatus" id="dsstatus" type="text" />
		
		<br />	
		
		<label for="insitapv"><? echo utf8ToHtml('Aprovação:') ?></label>
		<select name="insitapv" id="insitapv">
		<option value="0">0-Nao Analisado</option>
		<option value="1">1-Aprovado</option>
		<option value="2">2-Nao Aprovado</option>
		<option value="3">3-Restricao</option>
		<option value="4">4-Refazer</option>
		</select>

		<label for="cdopeap1"><? echo utf8ToHtml('Operador:') ?></label>
		<input name="cdopeap1" id="cdopeap1" type="text" />
		<br />	

		<label for="dtaprov1"><? echo utf8ToHtml('Data Aprovação:') ?></label>
		<input name="dtaprov1" id="dtaprov1" type="text" />
		
		<label for="hrtransa"><? echo utf8ToHtml('Hora:') ?></label>
		<input name="hrtransa" id="hrtransa" type="text" />

	</fieldset>		
	
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>
</div>
