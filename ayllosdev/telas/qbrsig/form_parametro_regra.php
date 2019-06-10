<?php
	/*!
	 * FONTE        : form_parametro_regra.php
	 * CRIAÇÃO      : Heitor - Mouts
	 * DATA CRIAÇÃO : 07/12/2018
	 * OBJETIVO     : Cadastro de parametros para a tela QBRSIG
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divParametroRegra" name="divParametroRegra">
	<form id="frmParametroRegra" name="frmParametroRegra" class="formulario" onSubmit="return false;" style="display:block">
		<fieldset id="fsparreg" style="display: none">
		<div id="tabParreg">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbParreg">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo Regra");?></th>
							<th><? echo utf8ToHtml("Nome Regra");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div>
		</div>
		</fieldset>
	</form>
</div>