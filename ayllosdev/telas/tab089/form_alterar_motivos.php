<?php
/*!
 * FONTE        : form_alterar_motivos.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 24/08/2018
 * OBJETIVO     : Formulario de alteracao da Tela TAB089 aba Motivos
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

<form id="frmAlterarMotivos" name="frmAlterarMotivos" class="formulario">
	
	<fieldset style="margin-top: 10px">

		<legend> <? echo utf8ToHtml('Motivos Anulação') ?> </legend>

		<label for="cdmotivo"><? echo utf8ToHtml('Código:') ?></label>
		<input type="text" id="cdmotivo" disabled/>

		<br style="clear:both" />
		
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

		<br style="clear:both" />

		<label for="idativo">Ativo:</label>		
		<input type="checkbox" id="idativo" />
		
	</fieldset>
</form>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onClick="buscaMotivos(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="alteraMotivo(); return false;">Concluir</a>
</div>
