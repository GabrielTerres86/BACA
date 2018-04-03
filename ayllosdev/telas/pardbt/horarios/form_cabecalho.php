<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Cabecalho para a tela PARDBT (Parametrização do Debitador Único 
 *                - Cadastro de Horários)
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"> C - Consultar  </option> 
					<option value="I"> I - Incluir  </option>
					<option value="E"> E - Excluir  </option>
                    <option value="H"> H - Histórico  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="acessoOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>