<?php
/* * *********************************************************************

  Fonte: form_cconsig.php
  Autor: Flavio - GFT
  Data : Julho/2018                      Última Alteração:

  Objetivo  : Mostrar form tela Consignado.

  Alterações: 
  

 * ********************************************************************* */

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();
?>

<form id="frmConsig" name="frmConsig" class="formulario">	
	
	<input type="hidden" id="tpmodconvenio" name="tpmodconvenio" value="<?php echo getByTagName($inf,'tpmodconvenio'); ?>" />
	<input type="hidden" id="indautrepassecc" name="indautrepassecc" value="<?php echo getByTagName($inf,'indautrepassecc'); ?>" />
	<input type="hidden" id="indinterromper" name="indinterromper" value="<?php echo getByTagName($inf,'indinterromper'); ?>"  />
	<input type="hidden" id="indalertaemailemp" name="indalertaemailemp" value="<?php echo getByTagName($inf,'indalertaemailemp'); ?>"  />
	<input type="hidden" id="indalertaemailconsig" name="indalertaemailconsig" value="<?php echo getByTagName($inf,'indalertaemailconsig'); ?>"  />
	<input type="hidden" id="dtvmtolt" name="dtmvtolt" value="<?php echo $glbvars["dtmvtolt"]; ?>" />

	<fieldset>

		<legend> <? echo utf8ToHtml('Informações gerais')?>  </legend>

		<!-- nmextemp -->
		<label for="nmextemp"><? echo utf8ToHtml('Raz&atilde;o Social') ?>:</label>
		<input
			type="text"
			id="nmextemp"
			name="nmextemp"
			value="<?php echo getByTagName($inf,'nmextemp');?>"
			class="campo"/>

		<br style="clear:both" />

		<!-- tpmodconvenio -->
		<label for="select_tpmodconvenio"><? echo utf8ToHtml('Tipo Conv&ecirc;nio') ?>:</label>
		<select 
			id="select_tpmodconvenio"
			name="select_tpmodconvenio"
			class="campo">
			<option
				<?php echo (getByTagName($inf,'tpmodconvenio') == 3 ? "selected" : "");?>
				value="3">
				<? echo utf8ToHtml('INSS') ?> 
			</option> 
			<option
				<?php echo (getByTagName($inf,'tpmodconvenio') == 2 ? "selected" : "");?>
				value="2">
			<? echo utf8ToHtml('P&uacute;blico') ?>
				
			</option> 
			<option
				<?php echo (getByTagName($inf,'tpmodconvenio') == 1 ? "selected" : "");?>
				value="1">
			<? echo utf8ToHtml('Privado') ?>
				
			</option> 
		</select>

		<br style="clear:both" />

		<!-- dtfchfol -->
		<label for="dtfchfol"><? echo utf8ToHtml('Dia Fechamento Folha') ?>:</label>
		<input 
			type="text"
			id="dtfchfol"
			name="dtfchfol"
			value="<?php echo getByTagName($inf,'dtfchfol');?>" 
			class="campo"/>

		<br style="clear:both" />

		<!-- nrdialimiterepasse -->
		<label for="nrdialimiterepasse"><? echo utf8ToHtml('Dia Limite para Repasse') ?>:</label>
		<input
			type="text"
			id="nrdialimiterepasse"
			name="nrdialimiterepasse"
			value="<?php echo getByTagName($inf,'nrdialimiterepasse');?>"
			class="campo"/>

		<br style="clear:both" />

		<!-- nrdialimiterepasse -->
		<label for="radio_indautrepassecc"><? echo utf8ToHtml('Autoriza d&eacute;bito repasse em c/c? ') ?></label>
			<label class="radio-inline">
				<input
					id="radio_indautrepassecc"
					name="radio_indautrepassecc"
					type="radio"
					value="1">
					<? echo utf8ToHtml('Sim') ?>
			</label>
			<label class="radio-inline">
				<input
					id="radio_indautrepassecc"
					name="radio_indautrepassecc"
					type="radio"
					value="0">
					<? echo utf8ToHtml('Não') ?>
			</label>

		<br style="clear:both" />

		<!-- indinterromper -->
		<label for="radio_indinterromper"><? echo utf8ToHtml('Interrompe Cobran&ccedil;a? ') ?></label>
			<label class="radio-inline">
				<input
					id="radio_indinterromper"
					name="radio_indinterromper"
					type="radio"
					value="1">
					<? echo utf8ToHtml('Sim') ?>
			</label>
			<label 
				class="radio-inline">
				<input
					id="radio_indinterromper"
					name="radio_indinterromper"
					type="radio"
					value="0">
					<? echo utf8ToHtml('Não') ?>
			</label>

		<br style="clear:both" />

		<!-- dtinterromper -->
		<label for="dtinterromper"><? echo utf8ToHtml('Data interrupção cobrança:') ?></label>
		<input 
			type="text"
			id="dtinterromper"
			name="dtinterromper"
			value="<?php echo getByTagName($inf,'dtinterromper');?>"
			class="campo"/>

		<br style="clear:both" />

		<label id="lbalertaconsig">Alertas Consig</label>
		<br style="clear:both">

		<!-- dsdemail -->
		<label for="dsdemail"><? echo utf8ToHtml('E-mail:') ?></label>
		<input 
			type="text"
			id="dsdemail"
			name="dsdemail"
			value="<?php echo getByTagName($inf,'dsdemail');?>"
			class="campo"/>

		<input
			type="checkbox" 
			id="checkbox_indalertaemailemp" 
			name="checkbox_indalertaemailemp" 
			value="1"/>

		<br style="clear:both" />

		<!-- dsdemailconsig -->
		<label for="dsdemailconsig"><? echo utf8ToHtml('E-mail Consig:') ?></label>
		<input
			type="text"
			id="dsdemailconsig"
			name="dsdemailconsig"
			value="<?php echo getByTagName($inf,'dsdemailconsig');?>"
			class="campo"/>
		
		<input
			type="checkbox"
			id="checkbox_indalertaemailconsig"
			name="checkbox_indalertaemailconsig"
			value="1">

	</fieldset>
</form>

<div id="divBotoesConsig" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
	<a 
		href="#"
		class="botao"
		id="btVoltar">
		Voltar
	</a>
	<a 
		href="#"
		class="botao"
		id="btConcluir">
		Concluir
	</a>

</div>

<div id="divVencParc" style="display:none">
	<? include("form_vencparc.php"); ?>
</div>
