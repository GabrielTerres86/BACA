<?php
	/*!
    * FONTE        : form_selecao_param.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : Cabecalho para a tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
?>
<div id="divSelParam" name="divSelParam">
	<form id="frmSelParam" name="frmSelParam" class="formulario cabecalho">		
		<fieldset id="fsSelParam">
			<legend style="text-align: center" ><? echo utf8ToHtml("Selecione a Parametriza&ccedil;&atilde;o desejada") ?></legend>
			<table width="100%">
				<tr>
					<td>			
						<label for="tpparam"></label>
						<select class="campo" id="tpparam" name="tpparam" >	
							<option value="PC"><? echo utf8ToHtml("Conta Contábil") ?></option>	
						    <option value="PH"><? echo utf8ToHtml("Histórico") ?></option>			
							<option value="PG"><? echo utf8ToHtml("Gerencial") ?></option>
							<option value="PR"><? echo utf8ToHtml("Risco Oper.") ?></option>	
						</select>
						<a href="#" class="botao" id="btnOKParam" name="btnOKParam" style = "text-align:right;">OK</a>
					</td>
				</tr>
			</table>
		</fieldset>
	</form>
</div>











