<?
/*!
 * FONTE        : form_filtros.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 11/03/2016
 * OBJETIVO     : Filtros para a tela HISTOR
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

<form id="frmFiltros" name="frmFiltros" class="formulario">
	
	<!-- Fieldset para os campos de filtro da consulta -->
	<fieldset id="fsetFiltroConsultar" name="fsetFiltroConsultar" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<table width="100%">
			<tr>
				<td>
					<label for="cdhistor"><? echo utf8ToHtml('Código:') ?></label>
					<input id="cdhistor" name="cdhistor" type="text"/>
				</td>
				<td>
					<label for="dshistor"><? echo utf8ToHtml('Descrição:') ?></label>
					<input id="dshistor" name="dshistor" type="text" class="campo alphanum" />
				</td>
				<td>
					<label for="tpltmvpq"><? echo utf8ToHtml('Lote:') ?></label>
					<input id="tpltmvpq" name="tpltmvpq" type="text"/>
				</td>
			</tr>
		</table>
	</fieldset>
</form>