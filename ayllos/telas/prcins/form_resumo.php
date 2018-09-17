<?php
	/*!
	 * FONTE        : form_resumo.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Tela de solicitação do resumo do processamento
	 * --------------
	 * ALTERAÇÕES   : 14/10/2015 - Ajustes para liberação (Adriano). 
	 *			     03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)		
	 * --------------
	 */
	 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmResumo" name="frmResumo" class="formulario" style="display:none;">

	<fieldset id="fsetFiltroResumo" name="fsetFiltroResumo" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Filtro</legend>
		
		<table width="100%">
			<tr>
				<td>
					<label for="cdcopaux">Cooperativa:</label>
					<select class="campo" id="cdcopaux" name="cdcopaux"></select>
				</td>
			</tr>
			<tr>
				<td>
					<label for="dtinicio">Per&iacute;odo:</label>
					<input id="dtinicio" name="dtinicio" type="text" value=""/>
						
					<label for="dtafinal">At&eacute;</label>
					<input type="text" name="dtafinal" id="dtafinal" value="" />	
				
				</td>
			</tr>
		</table>
	
	</fieldset>
	
	<fieldset id="fsetResumo" name="fsetResumo" style="padding:0px; margin:0px; padding-bottom:10px; display:none;">
		
		<legend>Resumo</legend>
		
		<div id="divResumo" name="divResumo">
			
		</div>
	
	</fieldset>
	
</form>