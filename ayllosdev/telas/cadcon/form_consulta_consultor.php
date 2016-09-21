<?php
	/*!
	 * FONTE        : form_consulta_consultor.php
	 * CRIAÇÃO      : Heitor Augusto Schmitt (RKAM)
	 * DATA CRIAÇÃO : 08/10/2015
	 * OBJETIVO     : Consulta de Consultores para a tela CADCON
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divConsultaConsultor" name="divConsultaConsultor">
	<form id="frmConConsultor" name="frmConConsultor" class="formulario" onSubmit="return false;" style="display:block">
		<label for="tbConcon"><? echo utf8ToHtml("Consultores:") ?></label>
		<br style="clear:both" />
		
		<div id="tabConcon">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbConcon">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Posi&ccedil;&atilde;o");?></th>
							<th><? echo utf8ToHtml("Consultor");?></th>
							<th><? echo utf8ToHtml("Data de inclus&atilde;o");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
		
		<br style="clear:both" />
		
		<label for="tbConage"><? echo utf8ToHtml("Ag&ecirc;ncias atendidas pelo consultor selecionado:") ?></label>
		<br style="clear:both" />
		<div id="tabConage">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbConage">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("Ag&ecirc;ncia");?></th>
							<th><? echo utf8ToHtml("Nome da Ag&ecirc;ncia");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>
	</form>
</div>