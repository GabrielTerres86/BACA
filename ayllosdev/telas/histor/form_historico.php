<?php
/*!
 * FONTE        : form_manter.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 30/09/2013
 * OBJETIVO     : Formulario de alteração e inclusão dos históricos da Tela HISTOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmHistorico" name="frmHistorico" class="formulario condensado">
	<div id="divHistorico" >

		<!-- Fieldset para os campos de DADOS GERAIS do historico -->
		<fieldset id="fsetDadosHistorico" name="fsetDadosHistorico" style="padding-bottom:10px;">
			
			<legend>Dados Gerais</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="cdhistor"><? echo utf8ToHtml('Código:') ?></label>
						<input id="cdhistor" name="cdhistor" type="text"/>
						<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaHistorico();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
					</td>
					<td colspan="2">
						<label for="cdhinovo"><? echo utf8ToHtml('Novo Codigo:') ?></label>
						<input id="cdhinovo" name="cdhinovo" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dshistor"><? echo utf8ToHtml('Hist&oacute;rico:') ?></label>
						<input id="dshistor" name="dshistor" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="indebcre"><? echo utf8ToHtml('D&eacute;bito/Cr&eacute;dito:') ?></label>
						<select name="indebcre" id="indebcre">
							<option value="D">D&eacute;bito</option> 
							<option value="C">Cr&eacute;dito</option> 
						</select>
					</td>
					<td>
						<label for="tplotmov"><? echo utf8ToHtml('Tipo do Lote:') ?></label>
						<input id="tplotmov" name="tplotmov" type="text"/>
					</td>
					<td>
						<label for="inhistor"><? echo utf8ToHtml('Ind. Fun&ccedil;&atilde;o:') ?></label>
						<input id="inhistor" name="inhistor" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dsexthst"><? echo utf8ToHtml('Descri&ccedil;&atilde;o Extensa:') ?></label>
						<input id="dsexthst" name="dsexthst" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="dsextrat"><? echo utf8ToHtml('Descri&ccedil;&atilde;o Extrato:') ?></label>
						<input id="dsextrat" name="dsextrat" type="text"/>
					</td>
				</tr>
				<tr>
					<td colspan="3">
						<label for="nmestrut"><? echo utf8ToHtml('Nome da Estrutura:') ?></label>
						<input id="nmestrut" name="nmestrut" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de indicadores do historico  -->
		<fieldset id="fsetIndicadores" name="fsetIndicadores" style="padding-bottom:10px;">
			
			<legend>Indicadores</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="indoipmf"><? echo utf8ToHtml('Indicador de Incidencia IPMF:') ?></label>
						<input id="indoipmf" name="indoipmf" type="text"/>
					</td>
					<td>
						<label for="inclasse"><? echo utf8ToHtml('Classe CPMF:') ?></label>
						<input id="inclasse" name="inclasse" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="inautori"><? echo utf8ToHtml('Ind. p/ autoriza&ccedil;&atilde;o d&eacute;bito:') ?></label>
						<select id="inautori" name="inautori">
							<option value="1"><? echo utf8ToHtml('Sim')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o') ?> </option>
						</select>
					</td>
					<td>
						<label for="inavisar"><? echo utf8ToHtml('Ind. de aviso p/ d&eacute;bito:') ?></label>
						<select id="inavisar" name="inavisar">
							<option value="1"><? echo utf8ToHtml('Sim')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o') ?> </option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="indcompl"><? echo utf8ToHtml('Indicador de Complemento:') ?></label>
						<select id="indcompl" name="indcompl">
							<option value="1"><? echo utf8ToHtml('Sim')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o') ?> </option>
						</select>
					</td>
					<td>
						<label for="indebcta"><? echo utf8ToHtml('Ind. Debito em Conta:') ?></label>
						<select id="indebcta" name="indebcta">
							<option value="1"><? echo utf8ToHtml('D&eacute;bito em conta')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o') ?> </option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="incremes"><? echo utf8ToHtml('Ind. p/Estat. Cr&eacute;dito do M&ecirc;s:') ?></label>
						<select id="incremes" name="incremes">
							<option value="1"><? echo utf8ToHtml('Soma na estatistica')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o soma') ?> </option>
						</select>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de dados contabeis do historico -->
		<fieldset id="fsetDadosContabeis" name="fsetDadosContabeis" style="padding-bottom:10px;">
			
			<legend>Dados Contabeis</legend>

			<table width="100%">
				<tr>
					<td colspan="2">
						<label for="cdhstctb"><? echo utf8ToHtml('Hist&oacute;rico Contabilidade:') ?></label>
						<input id="cdhstctb" name="cdhstctb" type="text" />
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="tpctbccu"><? echo utf8ToHtml('Tipo de Contab. Centro Custo:') ?></label>
						<select id="tpctbccu" name="tpctbccu">
							<option value="1"><? echo utf8ToHtml('1 - Por centro de custo')?> </option>
							<option value="0"><? echo utf8ToHtml('0 - N&atilde;o') ?> </option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<label for="tpctbcxa" ><? echo utf8ToHtml('Tipo Contab. Caixa:') ?></label>
						<select name="tpctbcxa" id="tpctbcxa">
							<option value="0"><? echo utf8ToHtml('0 - N&atilde;o tem tipo de contabiliza&ccedil;&atilde;o')?></option> 
							<option value="1"><? echo utf8ToHtml('1 - Contabiliza&ccedil;&atilde;o geral')?></option> 
							<option value="2"><? echo utf8ToHtml('2 - Contabiliza&ccedil;&atilde;o a d&eacute;bito por caixa')?></option> 
							<option value="3"><? echo utf8ToHtml('3 - Contabiliza&ccedil;&atilde;o a cr&eacute;dito por caixa')?></option> 
							<option value="4"><? echo utf8ToHtml('4 - Contabiliza&ccedil;&atilde;o a d&eacute;bito Banco do Brasil')?></option> 
							<option value="5"><? echo utf8ToHtml('5 - Contabiliza&ccedil;&atilde;o a cr&eacute;dito Banco do Brasil')?></option> 
							<option value="6"><? echo utf8ToHtml('6 - Contabiliza&ccedil;&atilde;o a d&eacute;bito Banco do Brasil')?></option> 
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrctacrd"><? echo utf8ToHtml('Conta a Creditar:') ?></label>
						<input id="nrctacrd" name="nrctacrd" type="text"/>
					</td>
					<td>
						<label for="nrctadeb"><? echo utf8ToHtml('Conta a Debitar:') ?></label>
						<input id="nrctadeb" name="nrctadeb" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="ingercre"><? echo utf8ToHtml('Gerencial a Credito:') ?></label>
						<select name="ingercre" id="ingercre">
							<option value="1">1 - N&atilde;o</option> 
							<option value="2">2 - Geral</option> 
							<option value="3">3 - PA</option> 
						</select>
					</td>
					<td>
						<label for="ingerdeb"><? echo utf8ToHtml('Gerencial a Debito:') ?></label>
						<select name="ingerdeb" id="ingerdeb">
							<option value="1">1 - N&atilde;o</option> 
							<option value="2">2 - Geral</option> 
							<option value="3">3 - PA</option> 
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="nrctatrc"><? echo utf8ToHtml('Conta Tarifa Credito:') ?></label>
						<input id="nrctatrc" name="nrctatrc" type="text"/>
					</td>
					<td>
						<label for="nrctatrd"><? echo utf8ToHtml('Conta Tarifa Debito:') ?></label>
						<input id="nrctatrd" name="nrctatrd" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de TARIFAS do historico -->
		<fieldset id="fsetTarifas" name="fsetTarifas" style="padding-bottom:10px;">
			
			<legend>Tarifas</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="vltarayl"><? echo utf8ToHtml('AYLLOS:') ?></label>
						<input id="vltarayl" name="vltarayl" type="text"/>
					</td>
					<td>
						<label for="vltarcxo"><? echo utf8ToHtml('CAIXA:') ?></label>
						<input id="vltarcxo" name="vltarcxo" type="text"/>
					</td>
					<td>
						<label for="vltarint"><? echo utf8ToHtml('INTERNET:') ?></label>
						<input id="vltarint" name="vltarint" type="text"/>
					</td>
					<td>
						<label for="vltarcsh"><? echo utf8ToHtml('CASH:') ?></label>
						<input id="vltarcsh" name="vltarcsh" type="text"/>
					</td>
				<tr>
			</table>
		</fieldset>

		<!-- Fieldset para os campos de TARIFAS do historico -->
		<fieldset id="fsetOutros" name="fsetOutros" style="padding-bottom:10px;">
			
			<legend>Outros</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="flgsenha"><? echo utf8ToHtml('Solicitar Senha:') ?></label>
						<select id="flgsenha" name="flgsenha">
							<option value="1"><? echo utf8ToHtml('Sim')?> </option>
							<option value="0"><? echo utf8ToHtml('N&atilde;o') ?> </option>
						</select>
					</td>
				</tr>
				<tr>
					<td>
						<label for="cdprodut"><? echo utf8ToHtml('Produto:') ?></label>
						<input name="cdprodut" id="cdprodut" type="text"/>
						<a style="margin-top:0px;" href="#" onClick="controlaPesquisaProduto(); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="dsprodut" id="dsprodut" type="text"/>
					</td>
				</tr>
				<tr>
					<td>
						<label for="cdagrupa"><? echo utf8ToHtml('Agrupamento:') ?></label>
						<input name="cdagrupa" id="cdagrupa" type="text"/>
						<a style="margin-top:0px;" href="#" onClick="controlaPesquisaAgrupamento(); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
						<input name="dsagrupa" id="dsagrupa" type="text"/>
					</td>
				<tr>
			</table>
		</fieldset>
	</div>
</form>