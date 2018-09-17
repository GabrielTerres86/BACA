<? 
 /*!
 * FONTE        : form_cadins.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 25/05/2011
 * OBJETIVO     : Formulário de exibição dados de cadastro
 * --------------
 * ALTERCAO     : 17/12/2012 - Ajuste para layout padrao (Daniel). 
 * --------------
 */	
?>

<form name="frmCadins" id="frmCadins" class="formulario" style="display:none">	
			
	
	<input id='auxconta' name="auxconta" type="hidden" value="" />
	<input id='cdagcpac' name="cdagcpac" type="hidden" value="" />
	<input id='nmrecben' name="nmrecben" type="hidden" value="" />	
		
	<fieldset>
		<legend><? echo utf8ToHtml('Dados do Benefício') ?></legend>
		
		<input id='cdaltcad' name="cdaltcad" type="hidden" value="" />
		
		<label for="nrbenefi"><? echo utf8ToHtml('NB:') ?></label>
		<input id='nrbenefi' name="nrbenefi" type="text" value="" />
		
		<label for="nrrecben"><? echo utf8ToHtml('NIT:') ?></label>
		<input id='nrrecben' name="nrrecben" type="text" value="" />
		<br />
		
		<label for="cdaginss"><? echo utf8ToHtml('Agência local INSS:') ?></label>
		<input id='cdaginss' name="cdaginss" type="text" value="" />
		
		<label for="nrcpfcgc"><? echo utf8ToHtml('CPF:') ?></label>
		<input id='nrcpfcgc' name="nrcpfcgc" type="text" value="" />
		<br />
											
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Dados do Pagamento') ?></legend>
		
		<label for="cdaltera"><? echo utf8ToHtml('Opções:') ?></label>
		<select name="cdaltera" id="cdaltera">
			<option value="0"></option>
		</select>
		<a href="#" class="botao" id="btCdaltera">OK</a>
		<br />
		
		<label for="nrdconta"><? echo utf8ToHtml('Conta corrente:') ?></label>
		<input id='nrdconta' name="nrdconta" type="text" value="" />
		
		<label for="nrnovcta"><? echo utf8ToHtml('Nova conta corrente:') ?></label>
		<input id='nrnovcta' name="nrnovcta" type="text" value="" />
		<br />
		
		<label for="nmprimtl"><? echo utf8ToHtml('Nome:') ?></label>
		<input id='nmprimtl' name="nmprimtl" type="text" value="" />
		<br />
		
		<label for="tpmepgto"><? echo utf8ToHtml('Meio de pagamento:') ?></label>
		<select name="tpmepgto" id="tpmepgto">
			<option value=""> - </option>
			<option value="1" ><? echo utf8ToHtml('Cartão/Recibo') ?></option>
			<option value="2">Conta</option>
		</select>
		
		<label for="tpnovmpg"><? echo utf8ToHtml('Novo meio de pagamento:') ?></label>
		<select name="tpnovmpg" id="tpnovmpg">
			<option value=""> - </option>
			<option value="1" ><? echo utf8ToHtml('Cartão/Recibo') ?></option>
			<option value="2">Conta</option>
		</select>
		<br />
		
		<label for="dtatucad"><? echo utf8ToHtml('Data da solicitação:') ?></label>
		<input id='dtatucad' name="dtatucad" type="text" value="" />
		
		<label for="dtdenvio"><? echo utf8ToHtml('Data do envio:') ?></label>
		<input name="dtdenvio" id='dtdenvio' type="text" value="" />
		<br />
											
	</fieldset>
				
</form>

<div id="divBotoes" style="margin-bottom:10px;display:none">	
	<a href="#" class="botao" id="btVoltar" >Voltar</a>
</div>