<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : 21/03/2018
 * OBJETIVO     : Cabecalho para a tela PARDBT
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
					<option value="A"> A - Alterar  </option>
                    <option value="H"> H - Histórico  </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="acessoOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>