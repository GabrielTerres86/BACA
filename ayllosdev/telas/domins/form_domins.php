<? 
 /*!
 * FONTE        : form_domins.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 24/05/2011 
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 29/11/2012 - Alterado botões do tipo tag <input> para
 *					           tag <a> novo layout (Daniel).
 * --------------
 */	
?>
<form name="frmDomins" id="frmDomins" class="formulario" style="display:none">	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Cadastros/Consultas') ?></legend>

		<input name="cdcooper" id="cdcooper" type="hidden" />
		<input name="nrdconta" id="nrdconta" type="hidden" />
		<input name="idseqttl" id="idseqttl" type="hidden" />
		<input name="cdagenci" id="cdagenci" type="hidden" />
		<input name="nmresage" id="nmresage" type="hidden" />
		<input name="nrctacre" id="nrctacre" type="hidden" />
		<input name="dsdircop" id="dsdircop" type="hidden" />
		<input name="nmextttl" id="nmextttl" type="hidden" />
		<input name="nmoperad" id="nmoperad" type="hidden" />
		<input name="nmcidade" id="nmcidade" type="hidden" />
		<input name="nmextcop" id="nmextcop" type="hidden" />
		<input name="nmrescop" id="nmrescop" type="hidden" />
		<input name="cdagebcb" id="cdagebcb" type="hidden" />
		<input name="dstextab" id="dstextab" type="hidden" />		
		
		<label for="nmrecben"><? echo utf8ToHtml('Nome do beneficiario:') ?></label>
		<input name="nmrecben" id="nmrecben" type="text" />

		<br />

		<label for="nrbenefi"><? echo utf8ToHtml('NB:') ?></label>
		<input name="nrbenefi" id="nrbenefi" type="text" />
		
		
		<label for="nrrecben"><? echo utf8ToHtml('NIT:') ?></label>
		<input name="nrrecben" id="nrrecben" type="text" />

		<br />
		
		<label for="nrnovcta"><? echo utf8ToHtml('Conta/dv para credito:') ?></label>
		<input name="nrnovcta" id="nrnovcta" type="text" />

		<label for="cdorgpag"><? echo utf8ToHtml('Orgão pagador:') ?></label>
		<input name="cdorgpag" id="cdorgpag" type="text" />
		
	</fieldset>		
			
</form>

<div id="divBotoes" style="margin-bottom:15px; display:none">	
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="manterRotina('A1'); return false;">Prosseguir</a>
</div>