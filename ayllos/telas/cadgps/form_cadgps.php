<? 
 /*!
 * FONTE        : form_cadgps.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 07/06/2011 
 * OBJETIVO     : Formulário de exibição do CADGPS
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */	
?>

<form name="frmCadgps" id="frmCadgps" class="formulario" onSubmit="return false;" style="display:none">	

	<fieldset>
	
		<legend><? echo utf8ToHtml('Dados da Conta') ?></legend>
	
		<label for="tpcontri"><? echo utf8ToHtml('Tipo:') ?></label>
		<select id="tpcontri" name="tpcontri" >
		<option value="1">1-Cliente/Outros</option>
		<option value="2">2-Propria Coop.</option>
		<option value="3">3-Prest. Servicos Propria Coop.</option>
		</select>		
		

		<label for="nrdconta"><? echo utf8ToHtml('Conta/dv contribuinte:') ?></label>
		<input name="nrdconta" id="nrdconta" type="text" />
		<a href="#" style="margin-top:5px" onClick="controlaPesquisas(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="idseqttl"><? echo utf8ToHtml('Seq. Ttl:') ?></label>
		<input name="idseqttl" id="idseqttl" type="text" />
		<a href="#" style="margin-top:5px" onClick="controlaPesquisas(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	</fieldset>	

	
	<fieldset>

		<legend><? echo utf8ToHtml('Dados do Contribuinte') ?></legend>
		<label for="nrcpfcgc"><? echo utf8ToHtml('Cpf/Cnpj:') ?></label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" />		

		<label for="nmprimtl"><? echo utf8ToHtml('Contribuinte:') ?></label>
		<input name="nmprimtl" id="nmprimtl" type="text" />		

	</fieldset>
		
	<fieldset>
		
		<legend><? echo utf8ToHtml('Endereço') ?></legend>
		
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" />
		<a href="#" style="margin-top:5px" onClick="controlaPesquisas(4);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<label for="dsendere"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendere" id="dsendere" type="text" />		
		<br />
		
		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" />

		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" />
		<br />

		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" />		

		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" />								
		<br />	

		<label for="cdufresd"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufresd', getByTagName($endereco,'cdufresd'), 1); ?>	

		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  />
	
	</fieldset>	

	<fieldset>
		<legend><? echo utf8ToHtml('Contato/Outros') ?></legend>

		<label for="nrfonres"><? echo utf8ToHtml('Fone:') ?></label>
		<input name="nrfonres" id="nrfonres" type="text" />		

		<label for="flgrgatv"><? echo utf8ToHtml('Ativo:') ?></label>
		<select id="flgrgatv" name="flgrgatv" >
		<option value=""></option>
		<option value="yes">Sim</option>
		<option value="no">Nao</option>
		</select>		

		<label for="debito11"><? echo utf8ToHtml('Débito autorizado:') ?></label>
		<select id="debito11" name="debito11" >
		<option value=""></option>
		<option value="yes">Sim</option>
		<option value="no">Nao</option>
		</select>		
		
	</fieldset>

	<div id="divBotoes">	
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="btnContinuar(); return false;">Prosseguir</a>
	</div>
	
</form>

