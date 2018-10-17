<?php
	/*!
	 * FONTE        : form_consulta_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Consulta de parametros para a tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divConsultaParametro" name="divConsultaParametro">
	<form id="frmConParametro" name="frmConParametro" class="formulario" onSubmit="return false;" style="display:block">
		
		<fieldset style="padding-top: 5px; display: block">

			<label for="cdtrnasa" ><? echo utf8ToHtml("Transa&ccedil;&atilde;o Bancoob:") ?></label>
			<input name="cdtrnasa" type="text"  id="cdtransa" class="inteiro campo" style="width: 50px;"/>
			<label for="cdhistor"><? echo utf8ToHtml("Hist&oacute;rico Ailos:") ?></label>
			<input name="cdhistor" type="text"  id="cdhistor" class="inteiro campo" style="width: 50px;"/>
			
			<a href="#" class="botao" id="btConsultar"   onClick="consultaParametro(); return false;">Consultar</a>			 			
		</fieldset>
		
			
		<div id="tabConcon" style="display: block">
		<fieldset style="padding-top: 5px; display: block">
		<legend>Transaçaões Bancoob</legend>
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbConcon">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo");?></th>
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o");?></th>
							<th><? echo utf8ToHtml("D/C");?></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</fieldset>
		</div>
		
				
		<div id="tabConhis" style="display: block">
		<fieldset style="padding-top: 5px;display: block">
		<legend>Histórico Ailos</legend>
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbConhis">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo");?></th>
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o");?></th>
							<th><? echo utf8ToHtml("D/C");?></th>
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