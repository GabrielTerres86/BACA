<?
/*!
 * FONTE        : form_juridico.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Formulário para Pessoa Jurídica da tela MATRIC
 * --------------
 * ALTERAÇÕES   : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 * --------------
 *				 09/07/2012: Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *
 *               09/07/2015 - Projeto Reformulacao Cadastral (Gabriel-RKAM). 
 *
 *				 
 *				 16/10/2017 - Removendo o campo caixa postal. (PRJ339 - Kelvin).
 */ 
?>

<form id="frmJuridico" name="frmJuridico" class="formulario condensado" style="width: 670px">
	
	<input type="hidden" name="cdtipcta" id="cdtipcta" value="<? echo getByTagName($registro,'cdtipcta') ?>" />
	<input type="hidden" name="rowidcem" id="rowidcem" value="<? echo getByTagName($registro,'rowidcem') ?>" />
	<input type="hidden" name="inconrfb" id="inconrfb" value="<? echo getByTagName($registro,'inconrfb') ?>" />

	
	<fieldset>
		<legend>Dados da Empresa</legend>
		
		<label for="nrcpfcgc">C.N.P.J.:</label>
		<input type="text" name="nrcpfcgc" id="nrcpfcgc" value="<? echo getByTagName($registro,'nrcpfcgc') ?>" />
		
		<label for="dtcnscpf">Consulta:</label>
		<input type="text" name="dtcnscpf" id="dtcnscpf" value="<? echo getByTagName($registro,'dtcnscpf') ?>" />
		
		<label for="cdsitcpf"><? echo utf8ToHtml('Situação:') ?></label>
		<select id="cdsitcpf" name="cdsitcpf">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($registro,'cdsitcpf') == "1"){ echo " selected"; } ?>> 1 - Regular</option>
			<option value="2" <? if (getByTagName($registro,'cdsitcpf') == "2"){ echo " selected"; } ?>> 2 - Pendente</option>
			<option value="3" <? if (getByTagName($registro,'cdsitcpf') == "3"){ echo " selected"; } ?>> 3 - Cancelado</option>
			<option value="4" <? if (getByTagName($registro,'cdsitcpf') == "4"){ echo " selected"; } ?>> 4 - Irregular</option>
			<option value="5" <? if (getByTagName($registro,'cdsitcpf') == "5"){ echo " selected"; } ?>> 5 - Suspenso</option>
		</select>	
		
		<br />
		
		<label for="nmprimtl"><? echo utf8ToHtml('Razão Social:') ?></label>
		<input type="text" name="nmprimtl" id="nmprimtl" value="<? echo getByTagName($registro,'nmprimtl') ?>" />
		
		<label for="nmfansia">Fantasia:</label>
		<input type="text" name="nmfansia" id="nmfansia" value="<? echo getByTagName($registro,'nmfansia') ?>" />
		<br />
		
		<label for="nmttlrfb">Nome RFB:</label>
		<input type="text" name="nmttlrfb" id="nmttlrfb" value="<? echo getByTagName($registro,'nmttlrfb') ?>" />
		<br />
			
		<label for="nrinsest">Insc.	Est.:</label>
		<input type="text" name="nrinsest" id="nrinsest" value="<? echo getByTagName($registro,'nrinsest') ?>" />
		
		<label for="natjurid"><? echo utf8ToHtml('Nat. Jurídica:') ?></label>
		<input type="text" name="natjurid" id="natjurid" value="<? echo getByTagName($registro,'natjurid') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="rsnatjur" id="rsnatjur" value="<? echo getByTagName($registro,'rsnatjur') ?>" />
		<br />		
		
		<label for="dtiniatv"><? echo utf8ToHtml('Início Ativ.:') ?></label>
		<input type="text" name="dtiniatv" id="dtiniatv" value="<? echo getByTagName($registro,'dtiniatv') ?>" />
		
		<label for="cdseteco"><? echo utf8ToHtml('Setor Econôm.:') ?></label>
		<input type="text" name="cdseteco" id="cdseteco" value="<? echo getByTagName($registro,'cdseteco') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="nmseteco" id="nmseteco" value="<? echo getByTagName($registro,'nmseteco') ?>" />
		<br />
		
		<label for="nrdddtfc">Telefone:</label>
		<input type="text" name="nrdddtfc" id="nrdddtfc" value="<? echo getByTagName($registro,'nrdddtfc') ?>" />
		<input type="text" name="nrtelefo" id="nrtelefo" value="<? echo getByTagName($registro,'nrtelefo') ?>" />
		
		<label for="cdrmativ">Ramo:</label>
		<input type="text" name="cdrmativ" id="cdrmativ" value="<? echo getByTagName($registro,'cdrmativ') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="dsrmativ" id="dsrmativ" value="<? echo getByTagName($registro,'dsrmativ') ?>" />
		<br style="clear:both" />
		
		<label for="dsdemail"><? echo utf8ToHtml('Email:') ?></label>
		<input name="dsdemail" id="dsdemail" type="text" value="<? echo getByTagName($registro,'dsdemail') ?>" />

		<label for="cdcnae">CNAE:</label>
		<input type="text" name="cdcnae" id="cdcnae" value="<? echo getByTagName($registro,'cdclcnae')  ?>" /> 
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="dscnae" id="dscnae" value="<? echo getByTagName($registro,'dscnae') ?>" />
		<br style="clear:both" />

		<label for="nrlicamb"><? echo utf8ToHtml('Nr da Licença:') ?></label>
		<input name="nrlicamb" id="nrlicamb" type="text" maxlength="15" value="<? echo getByTagName($registro,'nrlicamb') ?>" />
		<br style="clear:both" />

	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Endereço') ?></legend>

		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($registro,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<label for="dsendere"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($registro,'dsendere') ?>" />		
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($registro,'nrendere') ?>" />

		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($registro,'complend') ?>" />
		<br />

		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($registro,'cdufende'), 1); ?>		

		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($registro,'nmbairro') ?>" />								
		<br />	

		<label for="idorigee" class="rotulo"><? echo utf8ToHtml('Origem:'); ?></label>
		<select id="idorigee" name="idorigee">
			<option value=""> - </option>
			<option value="1" <? if (getByTagName($registro,'idorigee') == '1' ){ echo ' selected'; } ?>> Cooperado </option>
			<option value="2" <? if (getByTagName($registro,'idorigee') == '2' ){ echo ' selected'; } ?>> Cooperativa </option>
			<option value="3" <? if (getByTagName($registro,'idorigee') == '3' ){ echo ' selected'; } ?>> Terceiros </option>
		</select>

		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($registro,'nmcidade') ?>" />

		<br style="clear:both" />

	</fieldset>

	<fieldset>
		<legend><? echo utf8ToHtml('Entrada/Saída Cooperado') ?></legend>
		
		<label for="dtadmiss"><? echo utf8ToHtml('Admissão:') ?></label>
		<input type="text" name="dtadmiss" id="dtadmiss" value="<? echo getByTagName($registro,'dtadmiss') ?>" />
		
		<label for="dtdemiss"><? echo utf8ToHtml('Saída:') ?></label>
		<input type="text" name="dtdemiss" id="dtdemiss" value="<? echo getByTagName($registro,'dtdemiss') ?>" />
		
		<label for="cdmotdem">Motivo:</label>
		<input type="text" name="cdmotdem" id="cdmotdem" value="<? echo getByTagName($registro,'cdmotdem') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input type="text" name="dsmotdem" id="dsmotdem" value="<? echo getByTagName($registro,'dsmotdem') ?>" />
		<br style="clear:both" />
		
	</fieldset>	
	

</form>