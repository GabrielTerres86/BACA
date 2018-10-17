<?php
	/*!
	 * FONTE        : form_excluir_parametro.php
	 * CRIAÇÃO      : Alcemir Junior - Mout's
	 * DATA CRIAÇÃO : 21/09/2018
	 * OBJETIVO     : Exclusão de parametros para a tela PARCBA
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
?>
<div id="divExcluirParametro" name="divExcluirParametro">
	<form id="frmExcParametro" name="frmExcParametro" class="formulario" onSubmit="return false;" style="display:block">
		
		<fieldset id="fsexctra" >
		<legend>Transação Bancoob</legend>
					<label for="cdtransa"><? echo utf8ToHtml("C&oacute;digo:") ?></label>
					<input name="cdtransa" type="text"  id="cdtransa" class="inteiro campo" style="width: 50px;">
					<label for="dstransa"><? echo utf8ToHtml("Descri&ccedil;&atilde;o:") ?></label>
					<input name="dstransa" type="text"  id="dstransa" class="campoTelaSemBorda" style="width: 200px;" readonly disabled>		

					<label for="indebcre"><? echo utf8ToHtml("C/D:") ?></label>
					<select class="campo" id="indebcre" name="indebcre">
						<option value="C"><? echo utf8ToHtml("C") ?></option>
						<option value="D"><? echo utf8ToHtml("D") ?></option>
					</select>
			        
			        <a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;" onclick="IniciaExclusao(); return false;"><? 
			                   echo utf8ToHtml("OK");?></a>

        </fieldset>

        <div id="tabExcpar">
        <fieldset id="fsexcpar" style="display: none;">			
		<legend>Histórico Ailos</legend>
		
		
			<div class="divRegistros">			
				<table class="tituloRegistros" id="tbExcpar">
					<thead>
						<tr>
							<th><? echo utf8ToHtml("C&oacute;digo:");?></th>							
							<th><? echo utf8ToHtml("Descri&ccedil;&atilde;o:");?></th>
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