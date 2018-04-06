<?php
	/*!
	* FONTE        : form_filtros.php
	* CRIAÇÃO      : Douglas Quisinski
	* DATA CRIAÇÃO : 11/03/2016
	* OBJETIVO     : Filtros para a tela HISTOR
	* --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmFiltros" name="frmFiltros" class="formulario">
	
	<!-- Fieldset para os campos de filtro da consulta -->
	<fieldset id="fsetFiltroConsultar" name="fsetFiltroConsultar" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<table width="100%">
			<tr>
				<td>
					<label for="cdhistor">C&oacute;digo:</label>
					<input id="cdhistor" name="cdhistor" type="text"/>
				</td>
				<td>
					<label for="dshistor">Descri&ccedil;&atilde;o:</label>
					<input id="dshistor" name="dshistor" type="text" class="campo alphanum" />
				</td>
				<td>
					<label for="tpltmvpq">Lote:</label>
					<input id="tpltmvpq" name="tpltmvpq" type="text"/>
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<label for="cdgrupo_historico">Grupo de Hist&oacute;rico:</label>
					<input name="cdgrupo_historico" id="cdgrupo_historico" type="text"/>
					<a style="margin-top:0px;" href="#" onClick="controlaPesquisaGrupoHistorico('frmFiltros'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
					<input name="dsgrupo_historico" id="dsgrupo_historico" type="text"/>
				</td>
			</tr>
		</table>
	</fieldset>
</form>
