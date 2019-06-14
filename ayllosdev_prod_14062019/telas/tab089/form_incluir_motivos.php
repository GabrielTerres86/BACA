<?php
/*!
 * FONTE        : form_incluir_motivos.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 24/08/2018
 * OBJETIVO     : Formulario de inclusao da Tela TAB089 aba Motivos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmIncluirMotivos" name="frmIncluirMotivos" class="formulario">
	
	<fieldset style="margin-top: 10px">

		<legend> <? echo utf8ToHtml('Motivos Anulação') ?> </legend>

		<label for="dsmotivo">Motivo:</label>
		<input type="text" id="dsmotivo"/>

		<br style="clear:both" />
		
		<label for="tpproduto">Tipo Produto:</label>
		<select name="tpproduto" id="tpproduto">
			<option value="1"><? echo utf8ToHtml('Empréstimos') ?></option>
			<option value="3"><? echo utf8ToHtml('Desconto Títulos - Limite') ?></option>
		</select>

		<br style="clear:both" />

		<label for="inobservacao"><? echo utf8ToHtml('Observação:') ?></label>		
		<input type="checkbox" id="inobservacao" />
		
	</fieldset>
</form>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onClick="acessaAbaMotivos(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="incluiMotivo(); return false;">Concluir</a>
</div>
