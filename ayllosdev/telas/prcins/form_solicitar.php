<?php
	/*!
	 * FONTE        : form_solicitar.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Tela para solicitar 
	 * --------------
	 * ALTERAÇÕES   : 14/10/2015 - Ajuste para liberação (Adriano).
	 * --------------
	 */
	 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmSolicitar" name="frmSolicitar" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroSolicitar" name="fsetFiltroSolicitar" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>

		<table width="100%">
			<tr>
				<td>
					<label for="cdcopaux"><? echo utf8ToHtml("Cooperativa:"); ?></label>
					<select class="campo" id="cdcopaux" name="cdcopaux"></select>
				</td>
			</tr>
		</table>
		
	</fieldset>
	
	<fieldset id="fsetSolicitarResumo" name="fsetSolicitarResumo" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend>Resumo</legend>
		
		<div id="divSolicitarResumo" name="divSolicitarResumo">
					
		</div>
	
	</fieldset>
	
</form>