<?php
	/*!
	 * FONTE        : form_consulta_tarifa.php
	 * CRIA��O      : Alcemir Junior - Mout's
	 * DATA CRIA��O : 21/09/2018
	 * OBJETIVO     : Consulta de parametros para a tela PARCBA
	 * --------------
	 * ALTERA��ES   : 
	 * --------------
	 */
?>
<div id="divConsultaTarifa" name="divConsultaTarifa">
	<form id="frmConTarifa" name="frmConTarifa" class="formulario" onSubmit="return false;" style="display:block">
		<div id="tabContar" style="display: block">
		<fieldset style="padding-top: 5px; display: block">
		<legend>Tarifas Bancoob</legend>
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbContar">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Hist&oacute;rico");?></th>
							<th><? echo utf8ToHtml("Ds Cont&aacute;bil");?></th>
							<th><? echo utf8ToHtml("D&eacute;b PF");?></th>
							<th><? echo utf8ToHtml("Crd PF");?></th>
							<th><? echo utf8ToHtml("D&eacute;b PJ");?></th>
							<th><? echo utf8ToHtml("Crd PJ");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</fieldset>
		</div>
	</form>
</div>